
import UIKit

protocol CGFLoatConvertible {
  func makeCGFLoat(_value:NSNumber) -> CGFloat
}

extension CGFLoatConvertible {

  func makeCGFLoat(_value:NSNumber) -> CGFloat {
    if let value = _value as? Int {
      return CGFloat(value)
    } else if let value = _value as? Float {
      return CGFloat(value)
    } else {
      return CGFloat(_value as! NSNumber)
    }
  }
  
}




struct Locate {
  
  class Private {
    static func parse(_path:String, _function:String, _line:Int) -> String {
      let path     = Locate.path(_path)
      let function = Locate.function(_function)
      let line     = Locate.line(_line)
      return "::" + path + "::" + function + "::" + line + "::"
    }
  }
  
  static func debug(_path:String = #file, _function:String = #function, _line:Int = #line) -> String {
    return Private.parse(_path, _function:_function, _line:_line)
  }
  
  static func me(_path:String = #file, _function:String = #function, _line:Int = #line) -> String {
    print(Private.parse(_path, _function:_function, _line:_line))
    return ""
  }
  
  static func path(_path:String = #file) -> String {
    let file = _path.componentsSeparatedByString("/").last!
    return file.componentsSeparatedByString(".").first!
  }
  
  static func function(_function:String = #function) -> String {
    return _function.componentsSeparatedByString("(").first!
  }
  
  static func line(_line:Int = #line) -> String {
    return String(_line)
  }
  
}


struct LayoutAttribute {
  
  static func name(_attribute:NSLayoutAttribute) -> String {
    switch _attribute {
    case .Baseline: return ".Baseline"
    case .Bottom: return ".Bottom"
    case .BottomMargin: return ".BottomMargin"
    case .CenterX: return ".CenterX"
    case .CenterXWithinMargins: return ".CenterXWithinMargins"
    case .CenterY: return ".CenterY"
    case .CenterYWithinMargins: return ".CenterYWithinMargins"
    case .FirstBaseline: return ".FirstBaseline"
    case .Height: return ".Height"
    case .Leading: return ".Leading"
    case .LeadingMargin: return ".LeadingMargin"
    case .Left: return ".Left"
    case .LeftMargin: return ".LeftMargin"
    case .Right: return ".Right"
    case .RightMargin: return ".RightMargin"
    case .Top: return ".Top"
    case .TopMargin: return ".TopMargin"
    case .Trailing: return ".Trailing"
    case .TrailingMargin: return ".TrailingMargin"
    case .Width: return ".Width"
    default:
      return ""
    }
  }

}



protocol Binding: class {
  var location:String! {get}
  var description:String {get}
  
  var authority:AnyObject! {get}
  var restricted:AnyObject {get}
  
  var restrictedAttribute:NSLayoutAttribute {get}
  var authorityAttribute:NSLayoutAttribute {get}
  
  var relationship:NSLayoutRelation {get set}
  var multiplier:CGFloat {get set}
  var constant:CGFloat {get set}
}




class Constraint:Binding {
  var location:String!
  var description:String = ""
  
  var parent:AnyObject!
  var authority:AnyObject!
  var restricted:AnyObject
  
  var restrictedAttribute:NSLayoutAttribute = .NotAnAttribute
  var authorityAttribute:NSLayoutAttribute = .NotAnAttribute
  
  var relationship:NSLayoutRelation = .Equal
  var multiplier:CGFloat = CGFloat(1)
  var constant:CGFloat = CGFloat(0)
  
  init(
    restrict _restricted:AnyObject
    ,authority _authority:AnyObject? = nil
    ,parent _parent:AnyObject? = nil
    , _path:String = #file
    , _function:String = #function
    , _line:Int = #line
    ){
    restricted = _restricted
    authority  = _authority
    parent  = _parent
    location = Locate.debug(_path, _function:_function, _line:_line)
  }
  
  func describe(_value:NSNumber) -> String {
    return "[" + String(_value) + "]"
  }
  
  func constrain(){
    
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
    
    if let _ = authority {
      authority.addConstraint(restriction)
    } else {
      restricted.addConstraint(restriction)
    }
    description = ""
  }
  
}

protocol Constrainable:Binding {
  func constrain()
}





extension Constraint {
  
  func squareStatic(_value:NSNumber) -> Self {
    staticHeight(_value)
    relateEqual(.Width, restrict:.Height)
    return self
  }
  
}









extension Constraint:CGFLoatConvertible {
  
  func apply(
    _restricted:NSLayoutAttribute
    , _authority:NSLayoutAttribute? = nil
    , _relationship:NSLayoutRelation? = nil
    , _constant:NSNumber? = nil
    , _multiple:NSNumber? = nil)
  {
    
    restrictedAttribute  = _restricted
    
    if let authority = _authority {
      authorityAttribute  = authority
      description += "-Align" + LayoutAttribute.name(authority) + "|" + LayoutAttribute.name(_restricted)
    } else {
      authorityAttribute  = _restricted
      description += "-Same" + LayoutAttribute.name(_restricted)
    }
    
    if let relations = _relationship {
      relationship = relations
    }

    if let _  = _constant {
      description += describe(_constant!)
      constant = makeCGFLoat(_constant!)
    } else if let _ = _multiple {
      description += describe(_multiple!)
      multiplier = makeCGFLoat(_multiple!)
    }
      
    constrain()
  }
}
  
extension Constraint {

  func equal(_attribute:NSLayoutAttribute) -> Self {
    apply(_attribute)
    return self
  }
  
  func equalAlterFixed(_attribute:NSLayoutAttribute, constant _constant:NSNumber) -> Self {
    apply(_attribute, _constant:_constant)
    return self
  }
  
  func equalAlterRelative(_attribute:NSLayoutAttribute, multiple _multiple:NSNumber) -> Self {
    apply(_attribute, _multiple:_multiple)
    return self
  }
  
}


extension Constraint {
  
  func staticWidth(_constant:NSNumber) -> Self {
    apply(.Width, _constant:_constant)
    return self
  }
  
  func staticHeight(_constant:NSNumber) -> Self {
    apply(.Height, _constant:_constant)
    return self
  }
  
  func lineStaticWidth(_constant:NSNumber) {
    staticWidth(_constant)
    staticHeight(1)
  }
  
  func lineStaticHeight(_constant:NSNumber) {
    staticWidth(1)
    staticHeight(_constant)
  }
  
}

extension Constraint {
  
  func greaterOrSame(_attribute:NSLayoutAttribute) -> Self {
    apply(_attribute, _relationship:.GreaterThanOrEqual)
    return self
  }
  
  func greaterOrSameAlterFixed(_attribute:NSLayoutAttribute, constant _constant:NSNumber) -> Self {
    apply(_attribute, _relationship:.GreaterThanOrEqual, _constant:_constant)
    return self
  }
  
  func greaterOrSameAlterRelative(_attribute:NSLayoutAttribute, multiple _multiple:NSNumber) -> Self {
    apply(_attribute, _relationship:.GreaterThanOrEqual, _multiple:_multiple)
    return self
  }
  
}

extension Constraint {
  
  func lessOrSame(_attribute:NSLayoutAttribute) -> Self {
    apply(_attribute, _relationship:.LessThanOrEqual)
    return self
  }
  
  func lessOrSameAlterFixed(_attribute:NSLayoutAttribute, constant _constant:Int) -> Self {
    apply(_attribute, _relationship:.LessThanOrEqual, _constant:_constant)
    return self
  }
  
  func lessOrSameAlterRelative(_attribute:NSLayoutAttribute, multiple _multiple:NSNumber) -> Self {
    apply(_attribute, _relationship:.LessThanOrEqual, _multiple:_multiple)
    return self
  }
  
}

extension Constraint {
  
  func relateEqual(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute) -> Self {
    apply(_restricted, _authority:_authority)
    return self
  }
  
  func relateEqualAlterFixed(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, constant _constant:NSNumber) -> Self {
    apply(_restricted, _authority:_authority, _constant:_constant)
    return self
  }
  
  func relateEqualAlterRelative(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, multiple _multiple:NSNumber) -> Self {
    apply(_restricted, _authority:_authority, _multiple:_multiple)
    return self
  }
  
}

extension Constraint {
  
  func relateLessOrEqual(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.LessThanOrEqual)
    return self
  }
  
  func relateLessOrEqualAlterFixed(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, constant _constant:NSNumber) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.LessThanOrEqual, _constant:_constant)
    return self
  }
  
  func relateLessOrEqualAlterRelative(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, multiple _multiple:Float) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.LessThanOrEqual, _multiple:_multiple)
    return self
  }
  
}

extension Constraint {
  
  func relateGreaterOrEqual(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.LessThanOrEqual)
    return self
  }
  
  func relateGreaterOrEqualAlterFixed(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, constant _constant:Int) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.GreaterThanOrEqual, _constant:_constant)
    return self
  }
  
  func relateGreaterOrEqualAlterRelative(_authority:NSLayoutAttribute, restrict _restricted:NSLayoutAttribute, multiple _multiple:Float) -> Self {
    apply(_restricted, _authority:_authority, _relationship:.GreaterThanOrEqual, _multiple:_multiple)
    return self
  }
  
}

extension Constraint {
  
  func lineRelativeWidth(multiple _multiple:NSNumber) {
    equalAlterRelative(.Width, multiple:_multiple)
    staticHeight(1)
  }
  
  func lineRelativeHeight(multiple _multiple:NSNumber) {
    staticWidth(1)
    equalAlterRelative(.Height, multiple:_multiple)
  }
  
  func rectangleRelative(height _height:NSNumber, width _width:NSNumber) {
    equalAlterRelative(.Height, multiple:_height)
    equalAlterRelative(.Width, multiple:_width)
  }
  
  func rectangleStatic(height _height:NSNumber, width _width:NSNumber) {
    staticWidth(_height)
    staticHeight(_width)
  }
  
  func matchAll() {
    equal(.CenterX)
    equal(.CenterY)
    equal(.Height)
    equal(.Width)
  }
  
  func insetStatic(leading _leading:NSNumber, trailing _trailing:NSNumber, top _top:NSNumber, bottom _bottom:NSNumber) {
    relateEqualAlterFixed(.Leading, restrict:.Leading, constant:_leading)
    relateEqualAlterFixed(.Trailing, restrict:.Trailing, constant:_trailing)
    relateEqualAlterFixed(.Top, restrict:.Top, constant:_top)
    relateEqualAlterFixed(.Bottom, restrict:.Bottom, constant:_bottom)
  }
  
  func insetRelative(leading _leading:NSNumber, trailing _trailing:NSNumber, top _top:NSNumber, bottom _bottom:NSNumber) {
    relateEqualAlterRelative(.Leading, restrict:.Leading, multiple:_leading)
    relateEqualAlterRelative(.Trailing, restrict:.Trailing, multiple:_trailing)
    relateEqualAlterRelative(.Top, restrict:.Top, multiple:_top)
    relateEqualAlterRelative(.Bottom, restrict:.Bottom, multiple:_bottom)
  }
  
  func insetMargin() {
    relateEqual(.LeadingMargin, restrict:.Leading)
    relateEqual(.TrailingMargin, restrict:.Trailing)
    relateEqual(.TopMargin, restrict:.Top)
    relateEqual(.BottomMargin, restrict:.Bottom)
  }
  
  func insetUniformStatic(_constant:NSNumber) {
    insetStatic(leading: _constant, trailing: _constant, top: _constant, bottom: _constant)
  }
  
  func insetUniformRelative(_multiple:NSNumber) {
    insetRelative(leading: _multiple, trailing: _multiple, top: _multiple, bottom: _multiple)
  }
  
}









