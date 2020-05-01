//
//  Bindable.swift
//  MDRTAcademy
//
//  Created by Jim Joyce on 8/2/19.
//  Copyright © 2019 MDRT. All rights reserved.
//

import Foundation

class Bindable<T: Equatable> {
  typealias Subscriber = ((_ val: T?) -> Void)
  var subscriber: Subscriber?
  private var _value: T? {
    didSet {
      subscriber?(value)
    }
  }
  
  var value: T? {
    get { return _value }
    set {
      _value = newValue
    }
  }
  
  func unbind() -> Void {
    subscriber = nil
  }
  
  init(_ val: T?) {
    value = val
  }
  
  func didChange(_ val: T?) {
    value = val
  }
  
  func bind(to otherBindable: Bindable) -> Void {
    otherBindable.onChange(didChange)
  }
  
  func onChange(_ sub: @escaping Subscriber ) -> Void {
    subscriber = sub
  }
  
  deinit {
    subscriber = nil
  }
}
