//
//  ProfileViewController.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/19/21.
//

import UIKit

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var personalInfoBox: UIView!
    @IBOutlet weak var noteIconContainer: UIView!
    @IBOutlet weak var noteContainerBox: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var personalInfoShadowView: UIView!
    @IBOutlet weak var siteAdminTagView: SiteAdminTagView!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var blogLinkLabel: UILabel!
    @IBOutlet weak var dpImageView: CachingImageView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var sheetBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var sheetHeight: NSLayoutConstraint!
    
    var noteTextViewPlaceholder: UILabel?
    
    enum NoteState {
        case editing, notEditing, empty
    }
    
    var noteState: NoteState = .empty {
        didSet {
            handleNoteStateChange()
        }
    }
    
    var didSaveNote: ((String)->())?
    
    static var allProfiles: [String: UserProfileInfo] = [:]

    var viewModel: ProfileViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            title = viewModel.username
            fetchProfileInfo { [weak self] userProfileInfo in
                DispatchQueue.main.async {
                    self?.setValues(userProfileInfo)
                    self?.saveToAllProfilesAsObject(userProfileInfo)
                    UserProfileInfoCoreDataManager.save(userProfileInfo)
                }
            }
        }
    }
    @IBOutlet weak var noteBoxBottomConstraint: NSLayoutConstraint!
    
    @IBAction func editBtnTapped(_ sender: Any) {
        noteState = .editing
        noteTextView.becomeFirstResponder()
        noteBoxBottomConstraint.constant = 10
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        noteState = noteTextView.text.isEmpty ? .empty: .notEditing
        noteTextView.resignFirstResponder()
        
        guard let username = viewModel?.username else { return }
        let userNote = UserNote(username: username, noteBody: noteTextView.text)
        UserNoteCoreDataManager.save(userNote)
        UserNoteCoreDataManager.storage[username] = userNote.noteBody
        didSaveNote?(userNote.noteBody)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboardAppearanceInteractions()
        setSkeletonState(to: true)
        retrieveAllProfilesIfNeeded()
        setStoredValues()
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeInNetwork(_:)), name: .networkConnectionChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    @objc private func handleChangeInNetwork(_ notification: Notification) {
        if let data = notification.object as? [String: Bool],
           let isConnected = data["state"] {
            let noConnectionView = NoInternetRedView(frame: CGRect(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 0, width: view.frame.width, height: 30))
            let noConnectionViewTag = 1233211311
            noConnectionView.tag = noConnectionViewTag
            
            if isConnected {
                view.subviews.forEach{ view in
                    if view.tag == noConnectionViewTag {
                        view.removeFromSuperview()
                    }
                }
            } else {
                view.addSubview(noConnectionView)
            }
        }
    }
    
    private func handleNoteStateChange() {
        switch noteState {
        case .editing:
            saveButton.isHidden = false
            editButton.isHidden = true
            noteTextView.isEditable = true
            noteTextViewPlaceholder?.isHidden = true
            noteBoxBottomConstraint.constant = 0
        case .notEditing:
            saveButton.isHidden = true
            editButton.isHidden = false
            noteTextView.isEditable = false
            noteTextViewPlaceholder?.isHidden = true
            noteBoxBottomConstraint.constant = -24
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        case .empty:
            saveButton.isHidden = true
            editButton.isHidden = true
            noteTextView.isEditable = true
            noteTextViewPlaceholder?.isHidden = false
            noteBoxBottomConstraint.constant = -24
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setStoredValues() {
        if let viewModel = viewModel {
            if let storedProfileInfo = ProfileViewController.allProfiles[viewModel.username] {
                setValues(storedProfileInfo)
            }
            if let noteBody = UserNoteCoreDataManager.storage[viewModel.username],
               !noteBody.isEmpty {
                noteTextView.text = noteBody
            } else {
                noteTextView.text = ""
                noteState = .empty
            }
        }
    }
    
    private func retrieveAllProfilesIfNeeded() {
        if ProfileViewController.allProfiles.isEmpty {
            UserProfileInfoCoreDataManager.retrieveAll { result in
                switch result {
                case .failure(_):
                    break
                case .success(let profileInfoArray):
                    profileInfoArray.forEach{ saveToAllProfilesAsObject($0) }
                }
            }
        }
    }
    
    private func saveToAllProfilesAsObject(_ profileInfo: UserProfileInfo) {
        ProfileViewController.allProfiles[profileInfo.login] = profileInfo
    }
    
    private func setValues(_ userProfileInfo: UserProfileInfo) {
        fullNameLabel.text = userProfileInfo.name ?? viewModel?.username ?? ""
        companyLabel.text = userProfileInfo.company ?? ""
        blogLinkLabel.text = userProfileInfo.blog
        followersLabel.text = "\(userProfileInfo.followers)"
        followingLabel.text = "\(userProfileInfo.following)"
        
        dpImageView.loadImage(from: userProfileInfo.avatarUrl)
        siteAdminTagView.isHidden = !(viewModel?.isSiteAdmin ?? false)
        setSkeletonState(to: false)
    }
    
    private func setSkeletonState(to isOn: Bool) {
        followersLabel.backgroundColor = isOn ? .white: .clear
        followersLabel.textColor = isOn ? .clear: .white
        followingLabel.backgroundColor = isOn ? .white: .clear
        followingLabel.textColor = isOn ? .clear: .white
        fullNameLabel.backgroundColor = isOn ? .secondaryLabel: .clear
        fullNameLabel.textColor = isOn ? .clear: .label
        companyLabel.backgroundColor = isOn ? .secondaryLabel: .clear
        companyLabel.textColor = isOn ? .clear: .secondaryLabel
        blogLinkLabel.backgroundColor = isOn ? .secondaryLabel: .clear
        blogLinkLabel.textColor = isOn ? .clear: .systemBlue
        noteTextView.alpha = isOn ? 0: 1
    }
    
    private func setupViews() {
        bottomSheetView.layer.masksToBounds = true
        bottomSheetView.layer.cornerRadius = 20

        personalInfoBox.layer.masksToBounds = true
        personalInfoBox.layer.cornerRadius = 15
        
        dpImageView.layer.masksToBounds = true
        dpImageView.layer.cornerRadius = dpImageView.frame.height/2
        
        noteIconContainer.layer.masksToBounds = true
        noteIconContainer.layer.cornerRadius = 8
        
        noteContainerBox.layer.masksToBounds = true
        noteContainerBox.layer.cornerRadius = 8
        
        sheetHeight.constant = view.frame.height*(4/7)
        
        noteTextView.layer.masksToBounds = true
        noteTextView.layer.cornerRadius = 8
        noteTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        addPlaceHolderTextOnNoteTextView()
        noteTextView.delegate = self
    }
    
    private func addPlaceHolderTextOnNoteTextView() {
        noteTextViewPlaceholder = UILabel()
        guard let noteTextViewPlaceholder = noteTextViewPlaceholder else { return }
        noteTextViewPlaceholder.isHidden = true
        noteTextViewPlaceholder.text = "Enter a note here..."
        noteTextViewPlaceholder.textColor = noteTextView.textColor?.withAlphaComponent(0.5)
        noteTextViewPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.addSubview(noteTextViewPlaceholder)
        noteTextViewPlaceholder.topAnchor.constraint(equalTo: noteTextView.topAnchor, constant: 8).isActive = true
        noteTextViewPlaceholder.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor, constant: 7).isActive = true
    }
    
    private func setupKeyboardAppearanceInteractions() {
        NotificationCenter.default.addObserver(self,
           selector: #selector(self.keyboardNotification(notification:)),
           name: UIResponder.keyboardWillChangeFrameNotification,
           object: nil)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        let isKeyboardShown = keyboardFrame.minY == view.frame.height
        if isKeyboardShown {
            sheetBtmConstraint.constant = 0
            shadowView.alpha = 0
            personalInfoShadowView.alpha = 0
        } else {
            sheetBtmConstraint.constant = keyboardFrame.height - (bottomSheetView.frame.height - noteContainerBox.frame.maxY) + 33
            shadowView.alpha = 0.8
            personalInfoShadowView.alpha = 0.8
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func didTapOnView(recognizer: UIGestureRecognizer) {
        if noteState == .editing {
            noteTextView.resignFirstResponder()
            if noteTextView.text.isEmpty {
                noteState = .empty
            }
        }
    }
    
    private func fetchProfileInfo(completion: @escaping (UserProfileInfo)->()) {
        guard let username = viewModel?.username
        else {
            print("Error || No username found")
            return
        }
        SessionProvider().request(UserProfileInfo.self, service: UserService.getUser(username)) { result in
            switch result {
            case .failure(_):
                break
            case .success(let userProfile):
                completion(userProfile)
            }
        }
    }
    
    private func adjustTextViewHeight() {
        noteTextView.translatesAutoresizingMaskIntoConstraints = true
        noteTextView.sizeToFit()
        noteTextView.isScrollEnabled = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            noteState = .editing
        }
    }
}
