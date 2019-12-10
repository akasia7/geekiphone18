//
//  ImageButton.swift
//  Brio
//
//  Created by 永井夏樹 on 2019/11/14.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

class ImageButton: UIButton {

   @IBInspectable var unselectedImage: UIImage = UIImage()
       @IBInspectable var selectedImage: UIImage = UIImage()

       public var selectedStatus: Bool = false {
           didSet {
               setupImageView()
           }
       }

       override func awakeFromNib() {
           super.awakeFromNib()
           setupImageView()
       }

       override func prepareForInterfaceBuilder() {
           super.prepareForInterfaceBuilder()
           setupImageView()
           setNeedsDisplay()
       }

       private func setupImageView() {
           self.setImage(self.selectedStatus ? self.selectedImage : self.unselectedImage, for: .normal)
           self.setImage(self.selectedStatus ? self.selectedImage : self.unselectedImage, for: .highlighted)
           let animation = CASpringAnimation(keyPath: "transform.scale")
           animation.duration = 0.3 // animation時間
           animation.fromValue = 0.95 // animation前サイズ
           animation.toValue = 1.0 // animation前サイズ
           animation.mass = 0.6 // 質量
           animation.initialVelocity = 40.0 // 初速度
           animation.damping = 3.0 // 硬さ
           animation.stiffness = 40.0 // バネの弾性力
           imageView?.layer.add(animation, forKey: nil)
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               self.imageView?.layer.removeAllAnimations() // highlightのAnimationも含め、removeする
           }
       }
    
       override var isHighlighted: Bool {
          didSet {
              if isHighlighted {
                  if imageView?.layer.animation(forKey: "reduced-size") == nil {
                      let animation = CASpringAnimation(keyPath: "transform.scale")
                      animation.duration = 0.05 // animation時間
                      animation.fromValue = 1.0 // animation前サイズ
                      animation.toValue = 0.95 // animation後サイズ
                      animation.mass = 0.1 // 質量
                      animation.autoreverses = false // 自動でfromの値に戻らない
                      animation.initialVelocity = 40.0 // 初速度
                      animation.damping = 1.0 // 硬さ
                      animation.stiffness = 40.0 // バネの弾性力
                      animation.isRemovedOnCompletion = false // animation動作後に完了状態としない
                      animation.fillMode = .forwards // 一方向モード。fromの形状に戻らない
                      imageView?.layer.add(animation, forKey: "reduced-size")
                  }
              }
          }
      }
    
   
}


