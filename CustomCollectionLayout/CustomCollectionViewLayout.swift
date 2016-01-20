//
//  CustomCollectionViewLayout.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 15/12/2014.
//  Copyright (c) 2014 brightec. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    let numberOfColumns = 8
    var itemAttributes : NSMutableArray!
    var itemsSize : NSMutableArray!
    var contentSize : CGSize!
    
    override func prepareLayout() {
        if self.collectionView?.numberOfSections() == 0 {
            return
        }
        
        //กรณีที่สร้างไปแล้ว แค่เข้ามา Freeze Header Row/ Column ก็จบ
        if (self.itemAttributes != nil && self.itemAttributes.count > 0) {
            
            for section in 0..<self.collectionView!.numberOfSections() {
                let numberOfItems : Int = self.collectionView!.numberOfItemsInSection(section)
                for index in 0..<numberOfItems {
                    
                    if section != 0 && index != 0 {
                        continue
                    }
                    
                    let attributes : UICollectionViewLayoutAttributes = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: index, inSection: section))!
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = self.collectionView!.contentOffset.y
                        attributes.frame = frame
                    }
                    
                    if index == 0 {
                        var frame = attributes.frame
                        frame.origin.x = self.collectionView!.contentOffset.x
                        attributes.frame = frame
                    }
                }
            }
            return
        }
        
        //กรณีที่ยังไม่มี Attribute หรือเข้าครั้งแรก
        if (self.itemsSize == nil || self.itemsSize.count != numberOfColumns) {
            //เข้ามากำหนด Cell width/height ของ Item ตามจำนวน column ซึ่งกรณีนี้มี 8
            self.calculateItemsSize()
        }
        
        //initial ค่าก่อนการสร้าง attribute
        var column = 0
        var xOffset : CGFloat = 0
        var yOffset : CGFloat = 0
        var contentWidth : CGFloat = 0
        var contentHeight : CGFloat = 0
        
        //เริ่ม loop สร้าง row จาก numberOfSections ให้คิดว่า section คือ row
        for section in 0..<self.collectionView!.numberOfSections() {
            let sectionAttributes = NSMutableArray()
            //เริ่ม loop สร้าง column โดยให้ index คือ column
            for index in 0..<numberOfColumns {
                
                let itemSize = self.itemsSize[index].CGSizeValue()
                let indexPath = NSIndexPath(forItem: index, inSection: section) //เห็นไหมว่ามันเป็น row กับ column
                
                //สร้าง attribute ขึ้นมาตาม indexPath โดยจับยัด frame และ z-index เอาไว้ด้วยเผื่อกรณี freeze
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height))

                //column header จะอยู่สูงกว่า row header
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024;
                } else  if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = self.collectionView!.contentOffset.y //column header จะขยับตาม content offset แกน y ทำให้มองดูเหมือนติดอยู่ข้างบนตลอดเวลา
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = self.collectionView!.contentOffset.x //row header จะขยับตาม content offset แกน x ทำให้มองดูเหมือนติดอยู่ข้างซ้ายตลอดเวลา
                    attributes.frame = frame
                }
                
                //เก็บลง array ของ column
                sectionAttributes.addObject(attributes)
                
                xOffset += itemSize.width //ขยับ xOffset ออกไปเพื่อให้เป็น column ต่อไป
                column++
                
                //ถ้าเป็น column สุดท้าย ให้ทำการ reset xOffset แล้วก็ไปเพิ่ม yOffset แทนเพื่อเพิ่ม row ถัดไป
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            
            if (self.itemAttributes == nil) {
                self.itemAttributes = NSMutableArray(capacity: self.collectionView!.numberOfSections())
            }
            
            //เก็บลง array ของ row
            self.itemAttributes .addObject(sectionAttributes)
        }
        
        //ปรับขนาด content size ของ collectionView ตาม attribute ตัวสุดท้าย
        let attributes : UICollectionViewLayoutAttributes = self.itemAttributes.lastObject?.lastObject as! UICollectionViewLayoutAttributes
        contentHeight = attributes.frame.origin.y + attributes.frame.size.height
        self.contentSize = CGSizeMake(contentWidth, contentHeight)
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.itemAttributes[indexPath.section][indexPath.row] as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        if self.itemAttributes != nil {
            for section in self.itemAttributes {
                
                let filteredArray  =  section.filteredArrayUsingPredicate(
                    
                    NSPredicate(block: { (evaluatedObject, bindings) -> Bool in
                        return CGRectIntersectsRect(rect, evaluatedObject.frame)
                    })
                    ) as! [UICollectionViewLayoutAttributes]
                
                
                attributes.appendContentsOf(filteredArray)
                
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func sizeForItemWithColumnIndex(columnIndex: Int) -> CGSize {
        var text : String = ""
        switch (columnIndex) {
        case 0:
            text = "Col 0"
        case 1:
            text = "Col 1"
        case 2:
            text = "Col 2"
        case 3:
            text = "Col 3"
        case 4:
            text = "Col 4"
        case 5:
            text = "Col 5"
        case 6:
            text = "Col 6"
        default:
            text = "Col 7"
        }
        
        let size : CGSize = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)])
        let width : CGFloat = size.width + 25
        return CGSizeMake(width, 30)
    }
    
    func calculateItemsSize() {
        self.itemsSize = NSMutableArray(capacity: numberOfColumns)
        for index in 0..<numberOfColumns {
            self.itemsSize.addObject(NSValue(CGSize: self.sizeForItemWithColumnIndex(index)))
        }
    }
}