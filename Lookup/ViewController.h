//
//  ViewController.h
//  Lookup
//
//  Created by Robert Bastian on 05.05.13.
//  Copyright (c) 2013 Robert Bastian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UITextField* textField;
}

-(id)lookup:(NSString*)input;
-(IBAction)go:(id)sender;

@end
