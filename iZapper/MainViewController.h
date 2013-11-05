//
//  MainViewController.h
//  iZapper
//
//  Created by Rich Porter on 27/10/2013.
//  Copyright (c) 2013 Rich Porter. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NSStreamDelegate>


@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *drawOnSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colourSelectSegment;
@property (weak, nonatomic) IBOutlet UIPickerView *gridPicker;
@property (weak, nonatomic) IBOutlet UITextField *overwriteTextField;



- (IBAction)zapAction:(id)sender;
- (IBAction)clearKeyboardAction:(id)sender;




@end
