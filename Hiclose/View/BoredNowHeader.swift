//
//  BoredNowHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/24.
//

import UIKit

class BoredNowHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
    }
}
