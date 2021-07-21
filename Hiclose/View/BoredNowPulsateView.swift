//
//  BoredNowPulsateView.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/21.
//

import UIKit

class BoredNowPulsateView: UIView {
    
    //MARK: - Properties
    
    private var pulsatingLayer: CAShapeLayer!
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircleLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureCircleLayer() {
        pulsatingLayer = circleShapeLayer(strokeColor: .clear, fillColor: .init(white: 1, alpha: 0.6))
        layer.addSublayer(pulsatingLayer)
    }
    
    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 0)
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2.5,
                                        startAngle: -(.pi / 2), endAngle: 1.5 * .pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 12
        layer.fillColor = fillColor.cgColor
        layer.lineCap = .round
        layer.position = self.center
        
        return layer
    }
    
    func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.15
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsating")
    }
}
