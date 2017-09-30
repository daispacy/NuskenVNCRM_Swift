//
//  MYKxMenu.swift
//
//  Created by 尹子豪 on 16/3/16.
//  Copyright © 2016年 尹子豪. All rights reserved.
//
import Foundation
import UIKit


struct Color {
    let R: CGFloat
    let G: CGFloat
    let B: CGFloat
}

struct OptionalConfiguration {
    var font: UIFont?
    let arrowSize: CGFloat
    let marginXSpacing: CGFloat
    let marginYSpacing: CGFloat
    let intervalSpacing: CGFloat
    let menuCornerRadius: CGFloat
    let maskToBackground: Bool
    let shadowOfMenu: Bool
    let hasSeperatorLine: Bool
    let seperatorLineHasInsets: Bool
    let textColor: Color
    let menuBackgroundColor: Color
    let menuBackgroundColor1: Color
}

class KxMenuOverlay: UIView {
    
    init(frame: CGRect, maskSetting mask: Bool) {
        super.init(frame: frame)
        self.backgroundColor = mask ? UIColor.black.withAlphaComponent(0.17) : UIColor.clear
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.singleTap(recognizer:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func singleTap(recognizer: UITapGestureRecognizer) {
        for v: UIView in self.subviews {
            if (v.isKind(of:KxMenuView.self))  {
                KxMenu.sharedMenu().menuView.dismissMenu(noAnimated: true, shouldRemoveTarget: true)
            }
            
        }
    }
}

enum KxMenuViewArrowDirection {
    case None
    case Up
    case Down
    case Left
    case Right
}

struct Static {
    static var gMenu: KxMenu?
    static var gTintColor: UIColor?
}

class KxMenu: NSObject {
    var menuView: KxMenuView!
    
    var tintColor: UIColor? {
        get { return Static.gTintColor}
        set {if tintColor != Static.gTintColor {
            Static.gTintColor = tintColor
            }}
    }
    
    override init() {
        super.init()
    }
    
    private static var instance: KxMenu = {
        let instance = KxMenu()
        
        return instance
    }()
    
    class func sharedMenu() -> KxMenu  {
        
        return instance
    }
    
    func showMenuInView(view: UIView,fromRect rect: CGRect, menuItems: [KxMenuItem], withOptions options:OptionalConfiguration) {
        if !(self.menuView == nil) {
            menuView.dismissMenu(noAnimated: true,shouldRemoveTarget: false)
            self.menuView = nil
        }
        self.menuView = KxMenuView()
        self.menuView.showMenuInView(view: view, fromRect: rect, menuItems: menuItems, withOptions: options)
    }
    
    func dismissMenu() {
        if !(self.menuView == nil) {
            menuView.dismissMenu(noAnimated: true, shouldRemoveTarget: true)
            self.menuView = nil
        }
    }
    
    class func showMenuInView(view: UIView, fromRect rect: CGRect, menuItems: [KxMenuItem], withOptions options: OptionalConfiguration) {
        self.sharedMenu().showMenuInView(view: view, fromRect: rect, menuItems: menuItems, withOptions: options)
    }
    
    class func dismissMenu() {
        self.sharedMenu().dismissMenu()
    }
    
    
    
    
}

extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

class KxGradientView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: frame, isReverse: true)
        layer.cornerRadius = 5
    }
}

class KxMenuView: UIView {
    
    var kxMenuViewOptions: OptionalConfiguration!
    
    
    var arrowDirection: KxMenuViewArrowDirection!
    var arrowPosition: CGFloat!
    var contentView: UIView!
    var menuItems: [KxMenuItem]!
    
    var target:Any?
    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.isOpaque = true
        self.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupFrameInView(view: UIView,fromRect: CGRect) {
        let contentSize = self.contentView.frame.size
        let outerWidth = view.bounds.size.width
        let outerHeight = view.bounds.size.height
        
        let rectX0 = fromRect.origin.x
        let rectX1 = fromRect.origin.x + fromRect.size.width
        let rectXM = fromRect.origin.x + fromRect.size.width * 0.5
        let rectY0 = fromRect.origin.y
        let rectY1 = fromRect.origin.y + fromRect.size.height
        let rectYM = fromRect.origin.y + fromRect.size.height * 0.5
        
        let widthPlusArrow = contentSize.width + self.kxMenuViewOptions.arrowSize
        let heightPlusArrow = contentSize.height + self.kxMenuViewOptions.arrowSize
        let widthHalf = contentSize.width * 0.5
        let heightHalf = contentSize.height * 0.5
        
        let kMargin: CGFloat = 5
        
        if self.kxMenuViewOptions.shadowOfMenu {
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize.init(width: 2, height: 2)
            self.layer.shadowRadius = 2
            self.layer.shadowColor = UIColor.black.cgColor
        }
        
        if heightPlusArrow < (outerHeight - rectY1) {
            self.arrowDirection = .Up
            var point = CGPoint(x: rectXM - widthHalf, y: rectY1)
            if point.x < kMargin { point.x = kMargin }
            if (point.x + contentSize.width + kMargin) > outerWidth { point.x = outerWidth - contentSize.width - kMargin }
            self.arrowPosition = rectXM - point.x
            self.contentView.frame = CGRect(origin: CGPoint(x: 0, y: self.kxMenuViewOptions.arrowSize), size: contentSize)
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + self.kxMenuViewOptions.arrowSize))
        } else if heightPlusArrow < rectY0 {
            self.arrowDirection = .Down
            var point = CGPoint(x: rectXM - widthHalf, y: rectY0 - heightPlusArrow)
            if point.x < kMargin { point.x = kMargin }
            if (point.x + contentSize.width + kMargin) > outerWidth { point.x = outerWidth - contentSize.width - kMargin }
            self.arrowPosition = rectXM - point.x
            self.contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width, height: contentSize.height + self.kxMenuViewOptions.arrowSize))
        } else if widthPlusArrow < (outerWidth - rectX1) {
            self.arrowDirection = .Left
            var point = CGPoint(x: rectX1, y: rectYM - heightHalf)
            if point.y < kMargin { point.y = kMargin }
            if (point.y + contentSize.height + kMargin) > outerHeight { point.y = outerHeight - contentSize.height - kMargin }
            self.arrowPosition = rectYM - point.y
            self.contentView.frame = CGRect(origin: CGPoint(x: self.kxMenuViewOptions.arrowSize, y: 0), size: contentSize)
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width + self.kxMenuViewOptions.arrowSize, height: contentSize.height))
        } else if widthPlusArrow < rectX0 {
            self.arrowDirection = .Right
            var point = CGPoint(x: rectX0 - widthPlusArrow, y: rectYM - heightHalf)
            if point.y < kMargin { point.y = kMargin }
            if (point.y + contentSize.height + 5) > outerHeight { point.y = outerHeight - contentSize.height - kMargin }
            self.arrowPosition = rectYM - point.y
            self.contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
            self.frame = CGRect(origin: point, size: CGSize(width: contentSize.width  + self.kxMenuViewOptions.arrowSize, height: contentSize.height))
        } else {
            self.arrowDirection = .None
            self.frame = CGRect(origin: CGPoint(x: (outerWidth - contentSize.width)   * 0.5, y: (outerHeight - contentSize.height) * 0.5), size: contentSize)
        }
    }
    
    
    func showMenuInView(view: UIView,fromRect rect: CGRect, menuItems: [KxMenuItem],withOptions options: OptionalConfiguration) {
        self.kxMenuViewOptions = options
        self.menuItems = menuItems
        self.contentView = self.mkContentView()!
        self.addSubview(self.contentView)
        self.setupFrameInView(view: view, fromRect: rect)
        let overlay = KxMenuOverlay(frame: view.bounds, maskSetting: self.kxMenuViewOptions.maskToBackground)
        overlay.addSubview(self)
        view.addSubview(overlay)
        self.contentView.isHidden = true
        let toFrame = self.frame
        self.frame = CGRect(origin: self.arrowPoint(), size: CGSize(width: 1, height: 1))
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.alpha = 1
            self.frame = toFrame
        }) { (_) -> Void in
            self.contentView.isHidden = false
        }
    }
    
    
    @objc func dismissMenu(noAnimated: Bool,shouldRemoveTarget:Bool) {
        
        if !(self.superview == nil) {
            if !noAnimated {
                let toFrame = CGRect(origin: self.arrowPoint(), size: CGSize(width: 1, height: 1))
                self.contentView.isHidden = true
                //Menu收回动画
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.alpha = 0
                    self.frame = toFrame
                }, completion: { (_) -> Void in
                    if ((self.superview?.isEqual(KxMenuOverlay.self)) != nil) {
                        self.superview?.removeFromSuperview()
                        self.removeFromSuperview()
                    }
                })
            } else {
                if ((self.superview?.isEqual(KxMenuOverlay.self)) != nil) {
                    self.superview?.removeFromSuperview()
                    self.removeFromSuperview()
                }
            }
            
            //remove target after hide menu
            if shouldRemoveTarget {
                if let tar = target {
                    objc_setAssociatedObject(tar, &BlockCustomerView_associated, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
            
        }
    }
    
    
    func performAction(sender: AnyObject) {
        self.dismissMenu(noAnimated: true,shouldRemoveTarget: true)
        let button = sender as! UIButton
        let menuItem = self.menuItems[button.tag]
        menuItem.performAction()
    }
    
    
    func mkContentView() -> KxGradientView? {
        for v in self.subviews {
            v.removeFromSuperview()
        }
        
        if self.menuItems.count == 0 { return nil }
        
        let kMinMenuItemHeight: CGFloat = 32
        let kMinMenuItemWidth: CGFloat = 32
        
        let kMarginX = self.kxMenuViewOptions.marginXSpacing
        let kMarginY = self.kxMenuViewOptions.marginYSpacing
        
        if kxMenuViewOptions.font == nil { self.kxMenuViewOptions.font = UIFont.boldSystemFont(ofSize: 16) }
        
        var maxImageWidth: CGFloat = 0
        var maxItemHeight: CGFloat = 0
        var maxItemWidth: CGFloat = 0
        
        for menuItem in self.menuItems {
            if(menuItem.image == nil) {
                continue
            }
            let imageSize: CGSize = menuItem.image!.size
            if imageSize.width > maxImageWidth { maxImageWidth = imageSize.width }
        }
        
        if maxImageWidth > 0  { maxImageWidth += kMarginX }
        
        for menuItem in self.menuItems {
            let title = menuItem.title as NSString
            let titleSize: CGSize = title.size(attributes: [NSFontAttributeName: self.kxMenuViewOptions.font!])
            
            var imageSize: CGSize = CGSize.zero
            if(menuItem.image != nil) {
                imageSize = menuItem.image!.size
            }
            
            let itemHeight: CGFloat = max(titleSize.height, imageSize.height) + kMarginY * 2
            
            let itemWidth: CGFloat = ((!menuItem.enabled && (menuItem.image == nil)) ? titleSize.width : maxImageWidth + titleSize.width) + kMarginX * 2 + self.kxMenuViewOptions.intervalSpacing
            if itemHeight > maxItemHeight { maxItemHeight = itemHeight }
            if itemWidth > maxItemWidth { maxItemWidth = itemWidth }
        }
        
        maxItemWidth  = max(maxItemWidth, kMinMenuItemWidth)
        maxItemHeight = max(maxItemHeight, kMinMenuItemHeight)
        
        //let titleX: CGFloat = kMarginX * 2 + maxImageWidth;
        let titleX: CGFloat = maxImageWidth + self.kxMenuViewOptions.intervalSpacing
        let titleWidth: CGFloat = maxItemWidth - titleX - kMarginX * 2
        let selectedImage = UIImage.init(color: UIColor(hex:"0x018BBF"),size: CGSize(width: maxItemWidth, height: maxItemHeight + 2)) //KxMenuView.selectedImage(size: CGSize(width: maxItemWidth, height: maxItemHeight + 2))
        
        var insets: CGFloat = 0
        if self.kxMenuViewOptions.seperatorLineHasInsets { insets = 4 }
        
        let gradientLine = KxMenuView.gradientLine(size: CGSize(width: maxItemWidth - kMarginX * insets, height: 0.4))
        let contentView = KxGradientView(frame: CGRect.zero)
        contentView.autoresizingMask = []
//        contentView.backgroundColor = UIColor.clear
        contentView.isOpaque = false
        var itemY: CGFloat = kMarginY * 2
        var itemNum = 0
        for menuItem in self.menuItems {
            let itemFrame = CGRect(x: 0, y: itemY-kMarginY * 2 + self.kxMenuViewOptions.menuCornerRadius, width: maxItemWidth, height: maxItemHeight)
            let itemView = UIView(frame: itemFrame)
            itemView.autoresizingMask = []
            itemView.isOpaque = false
            contentView.addSubview(itemView)
            
            if menuItem.enabled {
                let button = UIButton(type: .custom)
                button.tag = itemNum
                button.frame = itemView.bounds
                button.backgroundColor = UIColor.clear
                button.isOpaque = false
                button.autoresizingMask = []
                button.addTarget(self, action: #selector((self.performAction(sender:))), for: .touchUpInside)
                button.setBackgroundImage(selectedImage, for: .highlighted)
                itemView.addSubview(button)
            }
            
            if menuItem.title.characters.count > 0 {
                let titleFrame = (!menuItem.enabled && (menuItem.image == nil)) ? CGRect(x: kMarginX * 2, y: kMarginY, width: maxItemWidth - kMarginX * 4, height: maxItemHeight - kMarginY * 2) : CGRect(x: titleX, y: kMarginY, width: titleWidth, height: maxItemHeight - kMarginY * 2)
                let titleLabel = UILabel(frame: titleFrame)
                titleLabel.text = menuItem.title
                titleLabel.font = self.kxMenuViewOptions.font
                if let alignment = menuItem.alignment {
                    titleLabel.textAlignment = alignment
                }
                //配置：menuItem字体颜色
                //titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor blackColor];
                titleLabel.textColor = UIColor(red: self.kxMenuViewOptions.textColor.R/255, green: self.kxMenuViewOptions.textColor.G/255, blue: self.kxMenuViewOptions.textColor.B/255, alpha: 1)
                titleLabel.backgroundColor = UIColor.clear                
                titleLabel.autoresizingMask = []
                itemView.addSubview(titleLabel)
            }
            if !(menuItem.image == nil) {
                let imageFrame = CGRect(x: kMarginX * 2, y: kMarginY, width: maxImageWidth, height: maxItemHeight - kMarginY * 2)
                let imageView = UIImageView(frame: imageFrame)
                imageView.image = menuItem.image
                imageView.clipsToBounds = true
                imageView.contentMode = .center
                imageView.autoresizingMask = []
                itemView.addSubview(imageView)
            }
            if itemNum < (self.menuItems.count - 1) {
                let gradientView = UIImageView(image: gradientLine)

                gradientView.frame = self.kxMenuViewOptions.seperatorLineHasInsets ? CGRect(origin: CGPoint(x: kMarginX * 2, y: maxItemHeight + 1), size: gradientLine.size) : CGRect(origin: CGPoint(x: 0, y: maxItemHeight + 1), size: gradientLine.size)
                gradientView.contentMode = .left

                if self.kxMenuViewOptions.hasSeperatorLine {
                    itemView.addSubview(gradientView)
                    itemY += 2
                }
                itemY += maxItemHeight
                
            }
            
            itemNum = itemNum+1
        }
        
        itemY += self.kxMenuViewOptions.menuCornerRadius
        contentView.frame = CGRect(x: 0, y: 0, width: maxItemWidth, height: itemY + kMarginY * 2 + 5.5 + self.kxMenuViewOptions.menuCornerRadius)
        return contentView
        
    }
    
    
    func arrowPoint() -> CGPoint {
        let point:CGPoint
        switch self.arrowDirection! {
        case .Up:
            
            point = CGPoint(x: self.frame.minX + self.arrowPosition, y: self.frame.minY)
        case .Down:
            point = CGPoint(x: self.frame.minX + self.arrowPosition, y: self.frame.minY)
        case .Left:
            point = CGPoint(x: self.frame.minX, y: self.frame.minY + self.arrowPosition)
        case .Right:
            point = CGPoint(x: self.frame.minX, y: self.frame.minY + self.arrowPosition)
        default:
            point = self.center
        }
        return point
    }
    
    
    class func selectedImage(size: CGSize) -> UIImage {
        let locations:[CGFloat] = [0,1]
        let components: [CGFloat] = [
            0.890,0.890,0.890,1,
            0.890,0.890,0.890,1
        ]
        return self.gradientImageWithSize(size: size, locations: locations, components: components, count: 2)
    }
    
    
    class func gradientLine(size: CGSize) -> UIImage {
        let locations:[CGFloat] = [0,0.2,0.5,0.8,1]
  
        let R: CGFloat = 255
        let G: CGFloat = 255
        let B: CGFloat = 255
        let components: [CGFloat] = [
            R,G,B,1,
            R,G,B,1,
            R,G,B,1,
            R,G,B,1,
            R,G,B,1
        ]
        return self.gradientImageWithSize(size: size, locations: locations, components: components, count: 5)
    }
    
    class func gradientImageWithSize(size: CGSize,locations: [CGFloat], components: [CGFloat], count: Int) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorGradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        context!.drawLinearGradient(colorGradient!, start: CGPoint.zero, end: CGPoint(x: size.width, y: 0), options: .drawsBeforeStartLocation)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    override func draw(_ rect: CGRect) {
        self.drawBackground(frame: self.bounds, inContext: UIGraphicsGetCurrentContext()!)
    }
    
    
    func drawBackground(frame: CGRect, inContext context: CGContext) {

        let R0: CGFloat = self.kxMenuViewOptions.menuBackgroundColor.R
        let G0: CGFloat = self.kxMenuViewOptions.menuBackgroundColor.G
        let B0: CGFloat = self.kxMenuViewOptions.menuBackgroundColor.B
        let R1 = self.kxMenuViewOptions.menuBackgroundColor1.R
        let G1 = self.kxMenuViewOptions.menuBackgroundColor1.G
        let B1 = self.kxMenuViewOptions.menuBackgroundColor1.B
        
        let tintColor = KxMenu().tintColor
        if !(tintColor == nil) {
            _ = tintColor?.rgb()
        }
        
        var X0 = frame.origin.x
        var X1 = frame.origin.x + frame.size.width
        var Y0 = frame.origin.y
        var Y1 = frame.origin.y + frame.size.height
        
        // render arrow
        let arrowPath = UIBezierPath()
        // fix the issue with gap of arrow's base if on the edge
        let kEmbedFix: CGFloat = 3
        
        switch self.arrowDirection! {
        case .Up:
            let arrowXM: CGFloat = self.arrowPosition
            let arrowX0: CGFloat = arrowXM - self.kxMenuViewOptions.arrowSize
            let arrowX1: CGFloat = arrowXM + self.kxMenuViewOptions.arrowSize
            let arrowY0: CGFloat = Y0
            let arrowY1: CGFloat = Y0 + self.kxMenuViewOptions.arrowSize + kEmbedFix
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY0))
            Theme.colorGradient.last!.set()
            Y0 += self.kxMenuViewOptions.arrowSize
        case .Down:
            let arrowXM: CGFloat = self.arrowPosition
            let arrowX0: CGFloat = arrowXM - self.kxMenuViewOptions.arrowSize
            let arrowX1: CGFloat = arrowXM + self.kxMenuViewOptions.arrowSize
            let arrowY0: CGFloat = Y1 - self.kxMenuViewOptions.arrowSize - kEmbedFix
            let arrowY1: CGFloat = Y1
            arrowPath.move(to: CGPoint(x: arrowXM, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowXM, y: arrowY1))
            Theme.colorGradient.first!.set()
            Y1 -= self.kxMenuViewOptions.arrowSize
        case .Left:
            let arrowYM: CGFloat = self.arrowPosition
            let arrowX0: CGFloat = X0
            let arrowX1: CGFloat = X0 + self.kxMenuViewOptions.arrowSize + kEmbedFix
            let arrowY0: CGFloat = arrowYM - self.kxMenuViewOptions.arrowSize
            let arrowY1: CGFloat = arrowYM + self.kxMenuViewOptions.arrowSize
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            UIColor(red: R0, green: G0, blue: B0, alpha: 1).set()
            X0 += self.kxMenuViewOptions.arrowSize
        case .Right:
            let arrowYM: CGFloat = self.arrowPosition
            let arrowX0: CGFloat = X1
            let arrowX1: CGFloat = X1 - self.kxMenuViewOptions.arrowSize - kEmbedFix
            let arrowY0: CGFloat = arrowYM - self.kxMenuViewOptions.arrowSize
            let arrowY1: CGFloat = arrowYM + self.kxMenuViewOptions.arrowSize
            arrowPath.move(to: CGPoint(x: arrowX0, y: arrowYM))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY0))
            arrowPath.addLine(to: CGPoint(x: arrowX1, y: arrowY1))
            arrowPath.addLine(to: CGPoint(x: arrowX0, y: arrowYM))
            UIColor(red: R1, green: G1, blue: B1, alpha: 1).set()
            X1 -= self.kxMenuViewOptions.arrowSize
        default:
            break
        }
        arrowPath.fill()
        
//        // render body
//        let bodyFrame = CGRect(x: X0, y: Y0, width: X1 - X0, height: Y1 - Y0)
//        //配置：这里修改菜单圆角
//        let borderPath = UIBezierPath(roundedRect: bodyFrame, cornerRadius: self.kxMenuViewOptions.menuCornerRadius)
//        let locations: [CGFloat] = [0.5, 0,0.5,1]
//        let components: [CGFloat] = [
//            R0, G0, B0, 1,
//            R1, G1, B1, 1,
//            ]
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let gradient = CGGradient(colorSpace: colorSpace,
//                                  colorComponents: components,
//                                  locations: locations,
//                                  count: MemoryLayout.size(ofValue: locations)/MemoryLayout.size(ofValue: locations[0]))
//
//        borderPath.addClip()
//
//        let start,end: CGPoint
//        if self.arrowDirection! == .Left || self.arrowDirection! == .Right {
//            start = CGPoint(x: X0, y: Y0)
//            end = CGPoint(x: X1, y: Y0)
//        } else {
//            start = CGPoint(x: X0, y: Y0)
//            end = CGPoint(x: X0, y: Y1)
//        }
//        context.drawLinearGradient(gradient!, start: start, end: end, options: .drawsBeforeStartLocation)
        
    }
}

class KxMenuItem: NSObject {
    
    var image: UIImage?
    var title: String
    var target: AnyObject?
    var action: Selector?
    var foreColor: UIColor?
    var alignment: NSTextAlignment?
    var enabled: Bool {
        return self.target != nil && self.action != nil
    }
    
    init(title: String, image: UIImage?, target: AnyObject, action: Selector) {
        self.title = title
        if(self.image != nil) {
            self.image = image
        }
        self.alignment = .center
        self.target = target
        self.action = action
        super.init()
    }
    
    func performAction() {
        if let target = self.target, let action = self.action {
            _ = target.perform(action, with: self)
        }
    }
    
}
