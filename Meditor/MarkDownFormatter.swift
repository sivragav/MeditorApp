//
//  Formatter.swift
//  Meditor
//
//  Created by Sivaprakash Ragavan on 10/27/15.
//  Copyright © 2015 Meditor. All rights reserved.
//

import Foundation
import Cocoa
import AppKit


class MarkDownFormatter : NSObject{
    
    
    static let sharedInstance = MarkDownFormatter()
    var lowAlphaColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    
    var h1:Attribute!
    var h2:Attribute!
    var emphasis:Attribute!
    var strongemphasis:Attribute!
    var UnOrderedList:Attribute!
    var OrderedList:Attribute!
    var link:Attribute!
    var blockQ:Attribute!
    
    
    
    class Attribute{
        var font:NSFont!
        var regex:NSRegularExpression!
        var para:NSMutableParagraphStyle!
        var syntaxRangeIndex:[Int] = []
        var italics: NSNumber = 0
        var color: NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        var isBullet:Bool = false
        var letterSpacing : NSNumber = 0
        var isLink: Bool = false
        var fontSize : CGFloat = 20.5
        
        
    }
    
    enum FormatError : ErrorType{
        case FontLoadingError
    }
    
    func setFont(attr:Attribute,fontName:String,size:CGFloat) throws  {
        attr.font = NSFont(name: fontName, size: size);
        if (attr.font == nil){
            throw FormatError.FontLoadingError
        }
    }
    
    func  H1init(){
        h1 = Attribute()
        do{
            try setFont(h1,fontName: "MyriadPro-SemiBold", size: 36)
        }catch FormatError.FontLoadingError {
            Swift.print("H1 Myriad Font not loading" )
            h1.font = NSFont.boldSystemFontOfSize(36)
           
        }catch let unknownError{
            Swift.print("H1 Myriad Font ERROR \(unknownError)")
        }
        h1.regex = try! NSRegularExpression(pattern: "(# )(.*)" , options: [NSRegularExpressionOptions.AnchorsMatchLines])
        h1.syntaxRangeIndex = [1]
        h1.para = getHeaderParagrahStyle()
        h1.letterSpacing = -0.5
        
    }
    
    
    func  H2Init(){
        h2 = Attribute()
        
        do{
            try setFont(h2,fontName: "MyriadPro-Regular", size: 28)
        }catch FormatError.FontLoadingError {
            Swift.print("H2 Myriad Font not loading")
            h2.font = NSFont.systemFontOfSize(28)
           
        }catch let unknownError{
            Swift.print("H2 Myriad Font ERROR \(unknownError)")
        }
        h2.regex = try! NSRegularExpression(pattern: "((\\n|^)## *)(.*)", options: [])
        h2.syntaxRangeIndex = [1]
        h2.para = getHeaderParagrahStyle()
        h2.color = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        h2.letterSpacing = 0
        
        
    }
    
    func strongEmphasisInit(){
        strongemphasis = Attribute()
        strongemphasis.font = NSFont(name: "Charter-Bold", size: strongemphasis.fontSize)!
        strongemphasis.regex = try! NSRegularExpression(pattern: "(\\*\\*|__)(.*?)(\\*\\*|__)", options: [])
        strongemphasis.syntaxRangeIndex = [1,3]
        strongemphasis.para = getDefaultParagraphStyle()
        
        
        
    }
    
    func emphasisInit(){
        emphasis = Attribute()
        emphasis.font = NSFont(name: "Charter-Italic", size: emphasis.fontSize)!
        emphasis.regex = try! NSRegularExpression(pattern: "(\\*|_)(.*?)(\\*|_)", options: [])
        emphasis.syntaxRangeIndex = [1,3]
        emphasis.para = getDefaultParagraphStyle()
        
    }
    
    func UnOrderedListInit(){
        UnOrderedList = Attribute()
        UnOrderedList.font = NSFont(name: "Charter", size: UnOrderedList.fontSize)!
        UnOrderedList.regex = try! NSRegularExpression(pattern: "((\\n|^)(\\s*)(\\*|-|\\+)\\s)(.*)", options: [])
        UnOrderedList.syntaxRangeIndex = []
        UnOrderedList.para = getListParagraphStyle()
        UnOrderedList.isBullet = true
    }
    
    func OrderedListInit(){
        OrderedList = Attribute()
        OrderedList.font = NSFont(name: "Charter", size: OrderedList.fontSize)!
        OrderedList.regex = try! NSRegularExpression(pattern: "((\\n|^)(\\s*)([0-9]+\\.)\\s)(.*)", options: [])
        OrderedList.syntaxRangeIndex = []
        OrderedList.para = getListParagraphStyle()
        OrderedList.isBullet = true
    }
    
    func linkInit(){
        link = Attribute()
        link.font = NSFont(name: "Charter", size: link.fontSize)!
        link.regex = try! NSRegularExpression(pattern: "(\\[)([^\\[]+)(\\]\\()([^\\)]+)(\\))", options: [])
        link.syntaxRangeIndex = [1,3,4,5]
        link.color = NSColor(red: 0.0, green: 0.0, blue: 0.7, alpha: 0.9)
        link.para = getDefaultParagraphStyle()
        link.isLink = true
        
        
        
    }
    
    // Big font, italics, 0.7
    func blockQuoteInit(){
       // NSFontManager.sharedFontManager().availableFonts
        blockQ = Attribute()
        blockQ.fontSize = 28
        blockQ.font = NSFont(name: "Charter-Italic", size: blockQ.fontSize)!
        blockQ.regex = try! NSRegularExpression(pattern: "(\\>)(.*)", options: [NSRegularExpressionOptions.AnchorsMatchLines])
        blockQ.syntaxRangeIndex = [1]
        blockQ.color = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.439216)
        //blockQ.italics = 0.30
        blockQ.para = getBQParagrahStyle()
        blockQ.para.alignment = NSTextAlignment.Center
    }
    
    //\[([^\[]+)\]\(([^\)]+)\)
    //((\n|^)\s*([0-9]+\.)\s)(.*)
    
    // Markdown
    ///(#+)(.*)/
    
    func  setup(){
        
        H1init()
        H2Init()
        strongEmphasisInit()
        emphasisInit()
        UnOrderedListInit()
        OrderedListInit()
        blockQuoteInit()
        linkInit()
        
    }
    func formatMarkDownSyntax(attributedText:NSMutableAttributedString,range : NSRange){
        attributedText.addAttribute(NSForegroundColorAttributeName, value: NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2), range: range)
    }
    
    func getHeaderParagrahStyle() -> NSMutableParagraphStyle{
        let style = NSMutableParagraphStyle();
        style.lineSpacing = -10;
        style.lineHeightMultiple = 1.2
        style.paragraphSpacing = 5
        style.paragraphSpacingBefore = 30
        return style
    }
    
    func getBQParagrahStyle() -> NSMutableParagraphStyle{
        let style = NSMutableParagraphStyle();
        style.lineSpacing = -10;
        style.lineHeightMultiple = 1.2
        style.paragraphSpacing = 30
        style.paragraphSpacingBefore = 30
        return style
    }
    
    
    func getDefaultParagraphStyle() -> NSMutableParagraphStyle{
        let style = NSMutableParagraphStyle();
        style.lineHeightMultiple = 1.3
        style.lineSpacing = 0;
        style.paragraphSpacing = 30
        style.paragraphSpacingBefore = 0
        return style
    }
    
    func getListParagraphStyle() -> NSMutableParagraphStyle {
        // let tabs:NSTextTab = NSTextTab.init(textAlignment: NSTextAlignment.Left,location:5.0, options:[:])
        let paraStyle = NSMutableParagraphStyle()
        //paraStyle.addTabStop(tabs)
        //paraStyle.defaultTabInterval = 2.0//5.0
        paraStyle.firstLineHeadIndent = 30
        //    paraStyle.headerLevel = 0
        //  paraStyle.headIndent = 7.0
        paraStyle.paragraphSpacing = 0
        paraStyle.paragraphSpacingBefore = 1.5//30//1.5
        paraStyle.lineSpacing = 5;
        paraStyle.lineHeightMultiple = 1.3
        
        return paraStyle
    }
    
    
    func getBulletIntend(match:NSTextCheckingResult!,attributedText:NSMutableAttributedString!,index:Int ){
        /*     var temp = match.rangeAtIndex[index]
        
        NSStringFromRange(temp)
        print(totalSpace)
        print(totalSpace.length)*/
        
    }
    
    
    
    func formatText( attributedText:NSMutableAttributedString!,format : Attribute, string : String?,lowAlpha:Bool) -> Bool  {
        var matched:Bool = false
        let range = NSMakeRange(0, (string?.characters.count)!)
        let matches = format.regex.matchesInString(string!, options: [], range: range)
        for match in matches {
            matched = true
            let matchRange = match.range
            if(h1.font != nil){
                attributedText.addAttribute(NSFontAttributeName, value: format.font, range: matchRange)
            }/*else{
                attributedText.addAttribute(NSFontAttributeName, value: NSFont.systemFontOfSize(format.fontSize), range: matchRange)
            }*/
            if(format.isLink){
              /*  let trimmedString =
                    format.regex.stringByReplacingMatchesInString( string!, options:NSRegularExpressionOptions, range:matchRange, withTemplate:"$4")*/
                let linkIndex = match.rangeAtIndex(4)
                let linkrange:Range<String.Index> = Range<String.Index>(start: string!.startIndex.advancedBy(linkIndex.location),end: string!.startIndex.advancedBy(linkIndex.location+linkIndex.length))
                let linkValue = string!.substringWithRange(linkrange)
                attributedText.addAttribute(NSLinkAttributeName, value:linkValue , range:match.rangeAtIndex(2))
            }
            //            attributedText.addAttribute(NSObliquenessAttributeName, value: format.italics, range: matchRange)
            if(format.isBullet){
                /* let ind :Int = 3
                let r = match.rangeAtIndex(ind);
                let index:Range<String.Index> = Range<String.Index>(r.location,r.location+r.length)
                
                let space:String  = string!.substringWithRange(index)                print(space+"1")
                let level = space.characters.count
                var mul:CGFloat = CGFloat(level)
                format.para.lineSpacing.advancedBy(mul)
                print(format.para.lineSpacing.description)*/
                
            }
            
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: format.para, range: matchRange)
            if(format.letterSpacing != 0){
                attributedText.addAttribute(NSKernAttributeName, value: format.letterSpacing, range: matchRange)
                
            }
            if(lowAlpha) {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: lowAlphaColor, range: matchRange)
            } else {
                attributedText.addAttribute(NSForegroundColorAttributeName, value: format.color, range: matchRange)
            }
            for index in format.syntaxRangeIndex{
                formatMarkDownSyntax(attributedText,range: match.rangeAtIndex(index))
            }
        }
        return matched;
    }
    
    func formatMarkdown(attributedText:NSMutableAttributedString!, string : String?,lowAlpha:Bool) {
        
        formatText(attributedText,format:h1,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:h2,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:UnOrderedList,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:OrderedList,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:link,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:blockQ,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:emphasis,string : string,lowAlpha:lowAlpha)
        formatText(attributedText,format:strongemphasis,string : string,lowAlpha:lowAlpha)
        
    }
    
    
    
    
}