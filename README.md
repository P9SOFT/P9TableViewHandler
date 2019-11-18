P9TableViewHandler
============

UITableView is useful type of view to listing items.
But, typing control code is a kind of boilerplate.
P9TableViewHandler library help you to handling UITableView easy and simple.

# Installation

You can download the latest framework files from our Release page.
P9TableViewHandler also available through CocoaPods. To install it simply add the following line to your Podfile.
pod ‘P9TableViewHandler’

# Simple Preview

```swift
let cellIdentifierForType:[String:String] = [ 
    "1" : SectionHeaderView.identifier(),
    "2" : CyanTableViewCell.identifier(),
    "3" : MagentaTableViewCell.identifier(),
    "4" : YellowTableViewCell.identifier(),
    "5" : BlackTableViewCell.identifier()
] 

let tableView = UITableView(frame .zero)

let handler = P9TableViewHandler()
handler.delegate = self
handler.standby(identifier:"sample", cellIdentifierForType: cellIdentifierForType, tableView: tableView)

var records:[P9TalveViewHandler.Record] = []
records.append(P9TableViewHandler.Record(type: "2", data: nil))
records.append(P9TableViewHandler.Record(type: "3", data: nil))

var sections:[P9TableViewHandler.Section] = []
sections.append(P9TableViewHandler.Section(headerType: "1", headerData: nil, footerType: nil, footerData: nil, records: records, extra: nil))

handler.setSections(section: sections)

func tableViewHandlerCellDidSelect(handlerIdentifier: String, cellIdentifier: String, indexPath: IndexPath, data: Any?, extra: Any?) {
    // handling tableview default select action
}

func tableViewHandlerCellEvent(handlerIdentifier: String, cellIdentifier: String, eventIdentifier: String?, data: Any?, extra: Any?) {
    // handling custom event from cell
}
```

Let's take a look around one by one.

# Make your tableview cell confirm the protocol

You need confirm and implement P9TableViewCellProtocol as below for your tableview cell to use P9TableViewHandler.

```swift
protocol P9TableViewCellProtocol: class {
    static func identifier() -> String
    static func instanceFromNib() -> UIView
    static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat
    func setData(_ data: Any?, extra: Any?)
    func setDelegate(_ delegate: P9TableViewCellDelegate)
}
```

identifier and instanceFromNib function need return its' identifier string and instance object for tableview cell.
But, these two function is optional. You don't need implement it, except that you want to do some customizing.
So, let the identifier function return the class name of your table view cell and instanceFromNib return a instance object for given class name from identifier.

cellHeightForData function need return the height of tableview cell for a given data.

```swift
static func cellHeightForData(_ data: Any?, extra: Any?) -> CGFloat {
    guard let data = data as? CellDataModel else {
        return 0
    }
    return data.height ?? 60
}
```

setData function pass the data and extra object for updating your tableview cell.
You can do your business code to update tableview cell.

```swift
func setData(_ data: Any?, extra: Any?) {
    guard let data = data as? CellDataModel else {
        return
    }
    self.data = data
    self.titleLabel.text = data.title ?? "Sample"
}
```

setDelegate function pass the callback object to feedback custom event.
If your tableview cell have some custom event, confirm P9TableViewCellDelegate first.

```swfit
protocol P9TableViewCellDelegate: class {
    
    func tableViewCellEvent(cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?)
}
```

and set delegate and feedback your custom event by it.

```swfit
func setDelegate(_ delegate: P9TableViewCellDelegate) {
    self.delegate = delegate
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    delegate?.tableViewCellEvent(cellIdentifier: SampleTableViewCell.identifier(), eventIdentifier: "touch", data: data, extra: nil)
}
```

If your project based on Objective C then, you need confirm and implement P9TableViewCellObjcProtocol for your tableview cell.
Not P9TableViewCellProtocol but P9TableViewCellObjcProtocol.
It have same member functions with P9TableViewCellProtocol, but you must implemnt all functions include identifier and instanceFromNib.

```objective-c
+ (NSString *)identifier {
    return @"SampleTableViewCell";
}

+ (UIView *)instanceFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:[SampleTableViewCell identifier] owner:nil options:nil] firstObject];
}
```

# Handling

Now, your tableview cells are ready.
Make dictionary for type key with your tableview cell identifiers.
Just make unique type key value as you wish or some type value from server response model.

```swift
let cellIdentifierForType:[String:String] = [ 
    "1" : CyanTableViewCell.identifier(),
    "2" : MagentaTableViewCell.identifier(),
    "3" : YellowTableViewCell.identifier(),
    "4" : BlackTableViewCell.identifier()
] 
```

Set them to handler.
And, dont't forget set delegate to get feedback from handler.

```swift
let handler = P9TableViewHandler()
handler.standby(identifier:"sample", cellIdentifierForType: cellIdentifierForType, tableView: tableView)
handler.delegate = self
```

And, you need to make model data for handler.
Don't worry, you can use your own model without any change. Just wrapping them into handler model.
Here is defintion of handler models.

```swift
@objc(P9TableViewRecord) public class Record : NSObject {
    var type:String
    var data:Any?
    var extra:Any?
    @objc public init(type:String, data:Any?, extra:Any?=nil) {
        self.type = type
        self.data = data
        self.extra = extra
    }
}
    
@objc(P9TableViewSection) public class Section : NSObject {
    var headerType:String?
    var headerData:Any?
    var footerType:String?
    var footerData:Any?
    var extra:Any?
    var records:[Record]?
    @objc public init(headerType:String?, headerData:Any?, footerType:String?, footerData:Any?, records:[Record]?, extra:Any?) {
        self.headerType = headerType
        self.headerData = headerData
        self.footerType = footerType
        self.footerData = footerData
        self.records = records
        self.extra = extra
    }
}
```

You can make model by N sections with M records within each sections as normal tableview data structure.
Make records, sections as you want and set them to handler.

```swift
var records:[P9TalveViewHandler.Record] = []
records.append(P9TableViewHandler.Record(type: "1", data: nil))
records.append(P9TableViewHandler.Record(type: "2", data: nil))

var sections:[P9TableViewHandler.Section] = []
sections.append(P9TableViewHandler.Section(headerType: nil, headerData: nil, footerType: nil, footerData: nil, records: records, extra: nil))

handler.setSections(section: sections)
```

And, reload targt tableview.

```swift
tableView.reloadData()
```

Now, get message from each tableview cells by confirm protocol P9TableViewHandlerDelegate.
Here is protocol and implement sample.

```swift
@objc public protocol P9TableViewHandlerDelegate: class {
    @objc optional func tableViewHandlerWillBeginDragging(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandlerDidScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandlerDidEndScroll(handlerIdentifier:String, contentSize:CGSize, contentOffset:CGPoint)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplayHeaderView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, willDisplayFooterView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    @objc optional func tableViewHandler(handlerIdentifier:String, didEndDisplayingFooterView view: UIView, forSection section: Int)
    @objc optional func tableViewHandlerCellDidSelect(handlerIdentifier:String, cellIdentifier:String, indexPath:IndexPath, data:Any?, extra:Any?)
    @objc optional func tableViewHandlerCellEvent(handlerIdentifier:String, cellIdentifier:String, eventIdentifier:String?, data:Any?, extra:Any?)
}
```

```swift
extension ViewController: P9TableViewHandlerDelegate {
    
    func tableViewHandlerCellDidSelect(handlerIdentifier: String, cellIdentifier: String, indexPath: IndexPath, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) indexPath \(indexPath.section):\(indexPath.row) did select")
    }
    
    func tableViewHandlerCellEvent(handlerIdentifier: String, cellIdentifier:String, eventIdentifier:String?, data: Any?, extra: Any?) {
        
        print("handler \(handlerIdentifier) cell \(cellIdentifier) event \(eventIdentifier ?? "")")
    }
}
```

# License

MIT License, where applicable. http://en.wikipedia.org/wiki/MIT_License
