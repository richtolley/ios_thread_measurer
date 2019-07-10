//
//  ViewController.swift
//  ThreadMeasurer
//
//  Created by Richard Tolley on 04/07/2019.
//  Copyright © 2019 Richard Tolley. All rights reserved.
//

import UIKit





class ViewController: UIViewController {

  var index = 0
  let thing = ["A", "B", "C", "D", "E", "F", "G"]
  let threadMeasurer = ThreadMeasurer()

  override func viewDidLoad() {
    super.viewDidLoad()

    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
      guard let strongSelf = self else { return }
      let usage = strongSelf.threadMeasurer.cpuUsageValues()

      let userUsage = usage.user > 500 ? 0 : usage.user

      let str = (0...userUsage).reduce("") { (acc,it) in acc + "*" }
     // print("user: \(str)")

      self?.threadMeasurer.reportMemory()
    }

    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
      guard let strongSelf = self else { return }
      strongSelf.startAnimation()
    }



    // Do any additional setup after loading the view.
  }

  @IBAction func clickButton(sender: Any?) {
    print("clickety click")
    self.runAThing()
  }

  func firstKey() -> String {
    index = index < thing.count-1 ? index + 1 : 0
    return thing[index]
  }


  func runAThing() {
    DispatchQueue.global().async { [weak self] in
      guard let strongSelf = self else { return }
      let key = strongSelf.firstKey()
      (0...1000000).forEach({ n in
        print("key: \(key) number: \(n)")
      })
    }
  }

  func randomPoint() -> CGPoint {

    let maxX = Int(self.view.frame.width)
    let maxY = Int(self.view.frame.height)

    guard let itemX = (0...maxX).randomElement() else { return .zero}
    guard let itemY = (0...maxY).randomElement() else { return .zero }
    return CGPoint(x: itemX, y: itemY)
  }

  func startAnimation() {
    if view.subviews.count == 100 {
      view.subviews.forEach { $0.removeFromSuperview() }
    } else {
      let image = UIImage(named: "jenkinsDevil")
      let imageView = UIImageView(image: image)
      view.addSubview(imageView)
      imageView.frame = CGRect(origin: randomPoint(), size: imageView.bounds.size)

      let animation = CABasicAnimation(keyPath: "transform.rotation")

      animation.fromValue = 0
      animation.toValue = CGFloat.pi * 2.0
      animation.repeatCount = 1000

      imageView.layer.add(animation, forKey: "rotation")
    }
  }
}

