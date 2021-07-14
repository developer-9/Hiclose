//
//  IntroController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/08.
//

import UIKit

protocol IntroControllerDelegate: AnyObject {
    func configure()
}

class IntroController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: IntroControllerDelegate?
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let picArray: [String] = ["0", "1", "2", "3", "4", "5"]
    
    private let presentLoginViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Let's Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.5
        button.layer.cornerRadius = 12
        button.backgroundColor = .mainBlueTint
        button.addTarget(self, action: #selector(presentLoginView), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        configureScrollView()
        createContentView()
        configurePageControl()
        
        scrollView.addSubview(presentLoginViewButton)
        presentLoginViewButton.frame = CGRect(x: view.frame.width * 5 + (view.frame.width / 4),
                                              y: view.frame.maxY - 160,
                                              width: view.frame.width / 2, height: 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    
    @objc func presentLoginView() {
        let controller = LoginController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func createImageView(name: String, int: Int) -> UIImageView {
        let iv = UIImageView(image: UIImage(named: name))
        let screenBounds: CGRect = UIScreen.main.bounds
        iv.frame = CGRect(x: screenBounds.width * CGFloat(int), y: 0,
                          width: screenBounds.width, height: screenBounds.height)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }
    
    private func createContentView() {
        for i in 0 ..< picArray.count {
            let iv = createImageView(name: picArray[i], int: i)
            scrollView.addSubview(iv)
        }
        view.addSubview(scrollView)
    }
    
    private func configureScrollView() {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(picArray.count),
                                        height: view.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
    }
    
    private func configurePageControl() {
        pageControl.frame = CGRect(x: 0, y: view.frame.maxY - 80, width: view.frame.maxX, height: 50)
        pageControl.pageIndicatorTintColor = UIColor.darkGray
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.numberOfPages = picArray.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        view.addSubview(pageControl)
    }
}

//MARK: - UIScrollViewDelegate

extension IntroController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
        }
    }
}

//MARK: - AuthenticationDelegate

extension IntroController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        delegate?.configure()
    }
}
