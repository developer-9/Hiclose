//
//  BoredNowHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/24.
//

import UIKit

class BoredNowHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
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
        backgroundColor = .red
    }
}
