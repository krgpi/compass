//
//  DrawMarker.swift
//  Polaris
//
//  Created by y.k.noaki on 2018/07/25.
//  Copyright © 2018年 y.k.noaki. All rights reserved.
//

import UIKit

class DrawMarker: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {

        let path = UIBezierPath()
        path.move(to:CGPoint(x:frame.midX, y:frame.midY))
        path.addLine(to: CGPoint(x:frame.midX, y:frame.minY+30))
        path.close()
        path.lineWidth = 15.0
        UIColor.white.setStroke()
        path.stroke()

        path.move(to: CGPoint(x:frame.midX-7.5, y:frame.minY+30))
        path.addLine(to: CGPoint(x:frame.midX, y:frame.minY))
        path.addLine(to: CGPoint(x:frame.midX+7.5, y:frame.minY+30))
        path.close()
        UIColor.white.setFill()
        path.fill()
        
        let southpath = UIBezierPath()
        southpath.move(to:CGPoint(x:frame.midX, y:frame.midY))
        southpath.addLine(to: CGPoint(x:frame.midX, y:frame.midY+45.0))
        southpath.close()
        southpath.lineWidth = 15.0
        UIColor.red.setStroke()
        southpath.stroke()
        
//        southpath.move(to: CGPoint(x:frame.midX-7.5, y:frame.minY+30))
//        southpath.addLine(to: CGPoint(x:frame.midX, y:frame.minY))
//        southpath.addLine(to: CGPoint(x:frame.midX+7.5, y:frame.minY+30))
//        southpath.close()
//        UIColor.red.setFill()
//        southpath.fill()
    }
}
