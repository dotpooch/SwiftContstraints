
import Cocoa

class Bind {
  
  var restricted:AnyObject
  var authority:AnyObject!
  var authorityBackup:AnyObject!
  var parent:AnyObject!
  var parentBackup:AnyObject!
  
  var restrictedAttribute:NSLayoutAttribute!
  var authorityAttribute:NSLayoutAttribute!
  
  var relationship:NSLayoutRelation = .Equal
  var multiplier:CGFloat = 1
  var constant:CGFloat = 0
  
  var function:String = ""
  var location:String = ""
  var description:String = ""
  var active:Bool = false
  
  init(restrict _restricted:AnyObject, _path:String = #file, _function:String = #function, _line:Int = #line) {
    //Debug.examine()
    restricted      = _restricted
    authority       = _restricted
    authorityBackup = _restricted
    parent          = _restricted
    parentBackup    = _restricted
  }
  
  convenience init(
    restrict _restricted:AnyObject
    ,parent _parent:AnyObject
    , _path:String = #file
    , _function:String = #function
    , _line:Int = #line
    ){
    self.init(restrict:_restricted, _path:_path, _function:_function, _line:_line)
    
    //Debug.examine()
    
    parent          = _parent
    parentBackup    = _parent
    
  }
  
  convenience init(
    restrict _restricted:AnyObject
    ,authority _authority:AnyObject
    , _path:String = #file
    , _function:String = #function
    , _line:Int = #line
    ){
    //Debug.examine()
    self.init(restrict:_restricted, _path:_path, _function:_function, _line:_line)
    
    authority       = _authority
    authorityBackup = _authority
    parent          = _authority
    parentBackup    = _authority
    
  }
  
  convenience init(
    restrict _restricted:AnyObject
    ,authority _authority:AnyObject
    ,parent _parent:AnyObject
    , _path:String = #file
    , _function:String = #function
    , _line:Int = #line
    ){
    //Debug.examine()
    self.init(restrict:_restricted, _path:_path, _function:_function, _line:_line)
    
    authority       = _authority
    authorityBackup = _authority
    parent          = _parent
    parentBackup    = _parent
  }
  
  func constrain() -> Bind {
//    Debug.examine("------- New Constraint -------")
//    Debug.examine(description)
//    Debug.examine(parent)
//    Debug.examine(restricted)
//    Debug.examine(Layout.reverse(restrictedAttribute))
//    Debug.examine(relationship)
//    Debug.examine(authority)
//    Debug.examine(Layout.reverse(authorityAttribute))
//    Debug.examine(multiplier)
//    Debug.examine(constant)
//    Debug.examine("------- -------")
    
    let restriction = NSLayoutConstraint(
      item:        restricted
      ,attribute:  restrictedAttribute
      ,relatedBy:  relationship
      ,toItem:     authority
      ,attribute:  authorityAttribute
      ,multiplier: multiplier
      ,constant:   constant
    )
    
    restriction.identifier = location + "" + description
    
    parent.addConstraint(restriction)
    
    resetDefaultValues()
    return self
  }
  
  func resetDefaultValues(){
    //Debug.examine()
    authority = authorityBackup
    parent = parentBackup
    
    restrictedAttribute = .NotAnAttribute
    authorityAttribute = .NotAnAttribute
    
    relationship = .Equal
    multiplier = CGFloat(1)
    constant = CGFloat(0)
    
    function = ""
    location = ""
    description = ""
    active = false
  }
  
  func setAttribute(_attribute:String, status:Status){
//    Debug.examine("status:")
//    Debug.examine(status)

    let attribute:NSLayoutAttribute = Layout.lookup(_attribute)
    
    
    switch status {
    case .restricted:
      restrictedAttribute = attribute
    case .authority:
      authorityAttribute = attribute
    case .simple:
      restrictedAttribute = attribute
      authorityAttribute = attribute
    }
    
    description += Layout.reverse(attribute)
  }
  
  
  func describeRelativeOffest(_value:AnyObject) {
    description += "[Relative:" + String(_value) + "]"
  }
  
  func describeStaticOffest(_value:AnyObject) {
    description += "[Static:" + String(_value) + "]"
  }
  
  func constrainActive(){
    if active == true {
      constrain()
    }
  }
  
  
  func single(_value:NSNumber, _function:String = #function) -> Bind {
    constrainActive()
    
    if ["__","apply","done"].contains(_function) == false {
      let attribute:NSLayoutAttribute = Layout.lookup(_function)
      
      authority = nil
      restrictedAttribute = attribute
      authorityAttribute  = .NotAnAttribute
      staticOffset(_value)
      description += String(Layout.reverse(attribute))
      
      active = true
    }
    return self
  }
  
  func simple(_function:String = #function) -> Bind {
    //Debug.examine()
    constrainActive()
    //Debug.examine()
    if ["__","apply","done"].contains(_function) == false {
      setAttribute(_function, status: .simple)
      active = true
    }
    //Debug.examine()
    return self
  }
  
  func complex(restricted _restricted:NSLayoutAttribute, authority _authority:NSLayoutAttribute, _function:String = #function) -> Bind {
    //Debug.examine()
    constrainActive()
    //Debug.examine()
    
    if ["__","apply","done"].contains(_function) == false {
      restrictedAttribute = _restricted
      authorityAttribute  = _authority
      description += Layout.reverse(_authority) + "{" + Layout.reverse(_restricted) + "}"
      active = true
    }
    
    //Debug.examine()
    return self
  }
  
  enum Status {
    case restricted
    case authority
    case simple
  }
  
  struct Layout {
    
    static func lookup(_attribute:String) -> NSLayoutAttribute {
      switch _attribute {
      case "baselines": return .Baseline
      case "bottoms": return .Bottom
      case "centerXs": return .CenterX
      case "centerYs" : return .CenterY
      case "firstBaselines" : return .FirstBaseline
      case "heights" : return .Height
      case "leadings" : return .Leading
      case "lefts" : return .Left
      case "rights" : return .Right
      case "tops" : return .Top
      case "trailings" : return .Trailing
      case "widths": return .Width
        
      case "baseline": return .Baseline
      case "bottom": return .Bottom
      case "centerX": return .CenterX
      case "centerY" : return .CenterY
      case "firstBaseline" : return .FirstBaseline
      case "height" : return .Height
      case "leading" : return .Leading
      case "left" : return .Left
      case "right" : return .Right
      case "top" : return .Top
      case "trailing" : return .Trailing
      case "width": return .Width
      default:
        return .NotAnAttribute
      }
    }
    
    static func reverse(_attribute:NSLayoutAttribute) -> String {
      switch _attribute {
      case .Baseline: return ".Baseline"
      case .Bottom: return ".Bottom"
      case .CenterX: return ".CenterX"
      case .CenterY: return ".CenterY"
      case .FirstBaseline: return ".FirstBaseline"
      case .Height: return ".Height"
      case .Leading: return ".Leading"
      case .Left: return ".Left"
      case .Right: return ".Right"
      case .Top: return ".Top"
      case .Trailing: return ".Trailing"
      case .Width: return ".Width"
      default:
        return ""
      }
    }
    
  }
  
}

extension Bind {
  
  var widths:Bind {return simple()}
  var heights:Bind {return simple()}
  var leadings:Bind {return simple()}
  var trailings:Bind {return simple()}
  var tops:Bind {return simple()}
  var bottoms:Bind {return simple()}
  var centerXs:Bind {return simple()}
  var centerYs:Bind {return simple()}
  
  var __:Bind {return simple()}
  var done:Bind {return simple()}
  var apply:Bind {return simple()}
  
  func top(_value:NSNumber) -> Bind {return single(_value)}
  func bottom(_value:NSNumber) -> Bind {return single(_value)}
  func leading(_value:NSNumber) -> Bind {return single(_value)}
  func trailing(_value:NSNumber) -> Bind {return single(_value)}
  func height(_value:NSNumber) -> Bind {return single(_value)}
  func width(_value:NSNumber) -> Bind {return single(_value)}
  
  var alignBelow:Bind {return complex(restricted:.Top, authority:.Bottom)}
  var alignAbove:Bind {return complex(restricted:.Bottom, authority:.Top)}
  var alignRight:Bind {return complex(restricted:.Leading, authority:.Trailing)}
  var alignLeft:Bind {return complex(restricted:.Trailing, authority:.Leading)}
  
  var alignAll:Bind {
    return heights.widths.centerXs.centerYs.__
  }
  
}

extension Bind {
  
  var canGrow:Bind {relationship = .GreaterThanOrEqual; return self}
  var canShrink:Bind {relationship = .LessThanOrEqual; return self}
  
  func staticOffset(_value:NSNumber) -> Bind {
    //Debug.examine()
    constant = CGFloat(_value)
    describeStaticOffest(_value)
    return self
  }
  
  func relativeOffset(_value:NSNumber) -> Bind {
    //Debug.examine()
    multiplier = CGFloat(_value)
    describeRelativeOffest(_value)
    return self
  }
  
}

extension Bind {
  
  func squareRestrictHeight() -> Bind {
    return complex(restricted:.Height, authority:.Width)
  }

  func squareRestrictWidth() -> Bind {
    return complex(restricted:.Width, authority:.Height)
  }
  
  func squareStatic(_value:NSNumber) -> Bind {
    return height(_value).width(_value).__
  }
  
}


extension Bind {
  
  func horizontalLineStatic(_value:NSNumber) -> Bind {
    return width(_value).height(1).__
  }
  
  func horizontalLineRelative(_value:NSNumber) -> Bind {
    return widths.relativeOffset(_value).height(1).__
  }
  
  func verticalLineStatic(_value:NSNumber) -> Bind {
    return height(_value).width(1).__
  }
  
  func verticalLineRelative(_value:NSNumber) -> Bind {
    return heights.relativeOffset(_value).width(1).__
  }
  
  func rectangleRelative(height _height:NSNumber, width _width:NSNumber) -> Bind {
    return heights.relativeOffset(_height).widths.relativeOffset(_width).__
  }
  
  func rectangleStatic(height _height:NSNumber, width _width:NSNumber) -> Bind {
    return height(_height).width(_width)
  }
  
  func insetStatic(_constant:NSNumber) -> Bind {
    for i in [leadings, trailings, tops, bottoms] {
      i.staticOffset(_constant).__
    }
    return self
  }
  
  func insetRelative(_multiple:NSNumber) -> Bind {
    for i in [leadings, trailings, tops, bottoms] {
      i.relativeOffset(_multiple).__
    }
    return self
  }
  
}
