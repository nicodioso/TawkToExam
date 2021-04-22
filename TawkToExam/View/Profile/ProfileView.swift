//
//  ProfileView.swift
//  TawkToExam
//
//  Created by Nico Adrianne Dioso on 4/19/21.
//

import UIKit

class ProfileView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let contentView = self.fromNib() else { fatalError() }
        addSubview(contentView)
    }
}
