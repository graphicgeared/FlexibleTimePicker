//
//  FlexibleTimePicker.swift
//  TimePicker
//
//  Created by ebru gungor on 02/01/2018.
//  Copyright © 2018 ebru gungor. All rights reserved.
//

import UIKit

@IBDesignable
public class FlexibleTimePicker: UIView, TimePickedDelegate {
    
    //MARK: Container
    
    @IBInspectable var fromCurrentHour: Bool = false
    @IBInspectable var startHour: Int = 1
    @IBInspectable var endHour: Int = 24
    
    @IBInspectable var allowsMultipleSelection: Bool = false
    @IBInspectable var scaleCellHeightToFit: Bool = false
    
    @IBInspectable var removeCellBorders:Bool = false
    
    var timeFrequency: TimeFrequency = .FullHour
    @IBInspectable var minuteFrequency : Int {
        get {
            return self.timeFrequency.rawValue
        }
        set( timeFrequency) {
            self.timeFrequency = TimeFrequency(rawValue: timeFrequency) ?? .FullHour
        }
    }
    
    //MARK: Cell
    
    @IBInspectable var cellThickness: CGFloat = 0.10
    @IBInspectable var cellBorderColor: UIColor! = UIColor.lightGray
    @IBInspectable var cellOnlyBottomBorder: Bool = false
    @IBInspectable var cellHeight: CGFloat = 40
    @IBInspectable var cellCountPerRow: Int = 4
    @IBInspectable var cellTextColor : UIColor = UIColor.black
    @IBInspectable var cellHighlightedTextColor: UIColor = UIColor.white
    @IBInspectable var cellBackgroundColor: UIColor = UIColor.white
    
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var collectionView: TimePickerCollectionView!
    
    private var chosenHours = [Hour]()
    
    //MARK: Init
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.setProperties(timeFrequency: timeFrequency,
                                          fromCurrentHour: fromCurrentHour,
                                          startHour: startHour,
                                          endHour: endHour,
                                          multipleSelection: allowsMultipleSelection,
                                          removeCellBorders: removeCellBorders,
                                          cellThickness: cellThickness,
                                          cellBorderColor: cellBorderColor,
                                          onlyBottomBorder: cellOnlyBottomBorder,
                                          scaleCellHeightToFit: scaleCellHeightToFit,
                                          cellHeight: cellHeight,
                                          cellCountPerRow: cellCountPerRow,
                                          cellTextColor: cellTextColor,
                                          cellHighlightedTextColor: cellHighlightedTextColor,
                                          cellBackgroundColor: cellBackgroundColor)
        self.collectionView.timeDelegate = self
    }
    
    private func commonInit() {
        Bundle(for: FlexibleTimePicker.self).loadNibNamed("FlexibleTimePicker", owner: self, options: nil)
        guard let content = view else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    //MARK: TimePickedDelegate
    
    func timePicked(chosenHours: [Hour]) {
        self.chosenHours = chosenHours
        print(getSelectedTimeSlots())
    }
    
    //MARK: UI
    
    public func setAvailability(availableHours:[AvailableHour]) {
        collectionView.setAvailability(availableHours:availableHours)
    }
    
    //MARK: Date
    
    public func getSelectedDateSlotsForDate(date:Date) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.shortDateFormat()
        let dateString = dateFormatter.string(from: date)
        let mappedArray = chosenHours.map({convertToDateFormat(dateString: dateString, hourString: $0.hourString, date: date)})
        return mappedArray
    }
    
    public func getSelectedDateSlotsForToday() -> [Date] {
        return self.getSelectedDateSlotsForDate(date: Date())
    }
    
    public func getSelectedTimeSlots() ->[String] {
        let timeSlots = self.chosenHours.map({getOnlyDateString(hour:$0)})
        return timeSlots
    }
    
    //MARK: Private
    
    private func getOnlyDateString(hour:Hour) -> String {
        return hour.hourString
    }
    
    private func convertToDateFormat(dateString: String, hourString:String, date:Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.longDateFormat()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
        let fullString = "\(dateString)T\(hourString):00.000Z"
        var dateUTC:Date?
        if hourString.hasPrefix("24") {
            dateUTC = self.getNextDayIfNeeded(date: date)
        } else {
            dateUTC = dateFormatter.date(from: fullString)!
        }
        return dateUTC!
    }
    
    private func getNextDayIfNeeded(date:Date) -> Date {
        let nextDay = date.dayAfter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Date.shortDateFormat()
        let dateString = dateFormatter.string(from: nextDay)
        let fullString = "\(dateString)T00:00:00.000Z"
        dateFormatter.dateFormat = Date.longDateFormat()
        return dateFormatter.date(from: fullString)!
    }
}
