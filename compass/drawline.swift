//
//  drawline.swift
//  Polaris
//
//  Created by y.k.noaki on 2018/07/25.
//  Copyright © 2018年 y.k.noaki. All rights reserved.
//

import UIKit
import Darwin

class DrawLine: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to:CGPoint(x:frame.width/2, y:frame.height))
        path.addLine(to: CGPoint(x:frame.width/2, y:0))
        path.move(to:CGPoint(x:0, y:frame.height/2))
        path.addLine(to: CGPoint(x:frame.width, y:frame.height/2))
//        path.close()
        path.lineWidth = 1.0
        UIColor.red.setStroke()
        path.stroke()
//        path.move(to:CGPoint(x:frame.width/2, y:frame.height/2))
        let radius = CGFloat(150)
        let outradius = CGFloat(170)
        var degree = CGFloat(0.0)
        for _ in 0..<36 {
            print(degree)
            path.move(to:CGPoint(x:frame.width/2 + radius * cos((degree / 360)*2*CGFloat.pi), y:frame.height/2 + radius * sin((degree / 360)*2*CGFloat.pi)))
            path.addLine(to:CGPoint(x:frame.width/2 + outradius * cos((degree / 360)*2*CGFloat.pi), y:frame.height/2 + outradius * sin((degree / 360)*2*CGFloat.pi)))
//            path.close()
            path.lineWidth = 1.0
            UIColor.red.setStroke()
            path.stroke()
            degree += 10
        }


        
    }
    
}


