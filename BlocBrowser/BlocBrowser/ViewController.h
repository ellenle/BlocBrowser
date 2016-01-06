//
//  ViewController.h
//  BlocBrowser
//
//  Created by Ellen Thuy Le on 11/28/15.
//  Copyright (c) 2015 Ellen Thuy Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//Replaces the web view with a fresh one, erasing all history. Also updates the URL field and toolbar buttons appropriately
-(void) resetWebView;

@end

