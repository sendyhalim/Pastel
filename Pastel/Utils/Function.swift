//
//  Function.swift
//  Pastel
//
//  Created by Sendy Halim on 2/14/16.
//  Copyright © 2016 Sendy Halim. All rights reserved.
//

func constantCall <A>(function: Void -> Void) -> A -> Void {
  return { (_: A) -> Void in
    function()
  }
}
