//
//  BoredNowController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/24.
//

import UIKit

class BoredNowController: UICollectionViewController {
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    private func configureUI() {
        collectionView.backgroundColor = .backgroundColor
        
    }
}

//MARK: - UICollectionViewDataSource

extension BoredNowController {
    
}

//MARK: - UICollectionViewDelegate

extension BoredNowController {
    
}
