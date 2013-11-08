//
//  MainViewController.m
//  iZapper
//
//  Created by Rich Porter on 27/10/2013.
//  Copyright (c) 2013 Rich Porter. All rights reserved.
//

#import "MainViewController.h"
#import "SimplePingHelper.h"

@interface MainViewController  ()
@property (nonatomic, retain) NSTimer* connectionTimeoutTimer;
@end

@implementation MainViewController {
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString * _ipAddress;
    NSArray *_sxga_sxga, *_hd_sxga, *_hd_hd, *_wuxga_sxga, *_wuxga_hd, *_wuxga_wuxga, *_gridNames;
    NSString *_R, *_G, *_B, *_C, *_Y, *_M, *_W, *_shadedRGB, *_chosenProjector, *_userRGB, *_pingReadout, *_drawCallFinished;
    int _gridBoxesWide, _gridBoxesHigh, _centerLeft, _centerRight, _middleTop, _middleBottom, _gridsize, _delayBtwLines, _thePort, everythingsOK;
    double _delayInSeconds, _tinyDelay;
    NSArray *_projGrid;
    NSInteger *_selectedGrid;
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//for testing set default ip manually
    _ipAddress = @"192.168.8.8";
    // set port number
    _thePort = 3002;
    //and set a default value for laziness
    [_ipTextField setText:_ipAddress];
    _pingReadout = @"FAIL";
    
    _gridNames = [NSArray arrayWithObjects:@"_sxga_sxga",@"hd_sxga", @"hd_hd", @"wuxga_sxga", @"wuxga_hd", @"wuxga_wuxga", nil];
    
    //Forces an array into _projGrid incase user doesnt touch UIPickerView
    _projGrid = _sxga_sxga;
    [_gridPicker selectedRowInComponent:0];
    
    //Colour Choices
    _R = @" 255 0 0)";
    _G = @" 0 255 0)";
    _B = @" 0 0 255)";
    _C = @" 0 255 255)";
    _Y = @" 255 255 0)";
    _M = @" 255 0 255)";
    _W = @" 255 255 255)";
    _shadedRGB = @" 64 64 64)";
    
    //_serRGB - Set to red for testing purposes
    //_userRGB = R;
    
    // the following 6 arrays are the values required to draw the blending grids in the varous scenarios
    // proj_grid = {xLineStart, yLineStart, xLineStop, yLineStop, hShadeStart, vShadeStart, hShadeWidth, vShadeHeight, xGrid, yGrid, xPanel, yPanel}
    _sxga_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1139],[NSNumber numberWithInt:1049], [NSNumber numberWithInt:512], [NSNumber numberWithInt:640], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1400], [NSNumber numberWithInt:1050], nil];
    _hd_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:260], [NSNumber numberWithInt:15],[NSNumber numberWithInt:1659],[NSNumber numberWithInt:1064], [NSNumber numberWithInt:528], [NSNumber numberWithInt:901], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1080], nil]; //VERIFIED
    _hd_hd = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1079], [NSNumber numberWithInt:512], [NSNumber numberWithInt:897], [NSNumber numberWithInt:55], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1079], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1080], nil]; //VERIFIED
    _wuxga_sxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:260], [NSNumber numberWithInt:75],[NSNumber numberWithInt:1659],[NSNumber numberWithInt:1124], [NSNumber numberWithInt:588], [NSNumber numberWithInt:901], [NSNumber numberWithInt:24], [NSNumber numberWithInt:118], [NSNumber numberWithInt:1399], [NSNumber numberWithInt:1049], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];
    _wuxga_hd = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:60],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1139], [NSNumber numberWithInt:573], [NSNumber numberWithInt:897], [NSNumber numberWithInt:54], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1179], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];
    _wuxga_wuxga = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],[NSNumber numberWithInt:1919],[NSNumber numberWithInt:1199], [NSNumber numberWithInt:577], [NSNumber numberWithInt:897], [NSNumber numberWithInt:46], [NSNumber numberWithInt:126], [NSNumber numberWithInt:1919], [NSNumber numberWithInt:1199], [NSNumber numberWithInt:1920], [NSNumber numberWithInt:1200], nil];
    
    _gridsize = 64;
    _delayBtwLines = 50;
    _delayInSeconds = 0.05f;
    _tinyDelay = 0.01f;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

//Runs when the user presses ZAP!
- (IBAction)zapAction:(id)sender {
    
    
    //Get IP Address
    
    int ipselfcheck = [self checkIPAdress];
    NSLog(@"ipselftest returned:%i", ipselfcheck);
    
    
    NSLog(@"Port number is set to %d", _thePort);
    
    //Start the Network stream to the projector
    
    if (ipselfcheck == 1){
        [self initNetworkCommunication];
        if ([_drawOnSegment selectedSegmentIndex] == 0) {
            [self sendThisMessage:@"(ITP5)"];
            NSLog(@"Sent (ITP5) for draw on black");
        }
        [self sendThisMessage:@"(UTP0)"];
        [self setupZap];
        [self drawCall];
        
        
        NSLog(@"ZAPCALL: drawCallFinished: %@", _drawCallFinished);
    } else {
        
    UIAlertView *ipProblem = [[UIAlertView alloc]
                                     initWithTitle:@"IPProblem"
                                     message:@"You've got IP Issues"
                                     delegate:nil
                                     cancelButtonTitle:@"Bad Times"
                                     otherButtonTitles:nil];
    [ipProblem show];
    }
}

//Draws the grid yo!
-(void) drawCall {
    NSLog(@"Inititated Draw Call...");
    NSLog(@"drawCallFinished:%@", _drawCallFinished);
    NSDate *drawCallStart = [NSDate date];
    
    int i = 0;
    while (i < [[_projGrid objectAtIndex:7] integerValue]){
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",([[_projGrid objectAtIndex:5] integerValue]+i)])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:5] integerValue]+i)])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
        [self sendThisMessage:_shadedRGB];
        //NSLog(@"Vertical Shading has executed %i times", i);
        [NSThread sleepForTimeInterval:_tinyDelay];
        i++;
    }
    i = 0;
    while (i < [[_projGrid objectAtIndex:6]integerValue]){
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:[NSString stringWithFormat:@"%ld",
                               (long)
                               ([[_projGrid objectAtIndex:0] integerValue])]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:4] integerValue]+i)])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:2] integerValue]])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:4] integerValue]+i)])];
        [self sendThisMessage:_shadedRGB];
        // NSLog(@"Horizontal Shading has executed %i times", i);
        [NSThread sleepForTimeInterval:_tinyDelay];
        i++;
    }
    i = 0;
    
    while (i < (_gridBoxesWide/2) ){
        //vert lines from left edge to center
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:[NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:0] integerValue]+(i * _gridsize))]];
        [self sendThisMessage:@" "];
        [self sendThisMessage
         
         :([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:[NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:0] integerValue]+(i * _gridsize))]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
        [self sendThisMessage:_userRGB];
        //NSLog(@"VertLeft to Center Shading has executed %i times", i);
        [NSThread sleepForTimeInterval:_delayInSeconds];
        //vert lins from right edge to center
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:[NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:2] integerValue]-(i * _gridsize))]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:[NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:2] integerValue]-(i * _gridsize))]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
        [self sendThisMessage:_userRGB];
        
        // NSLog(@"VertRight to Center Shading has executed %i times", i);
        [NSThread sleepForTimeInterval:_delayInSeconds];
        i++;
    }
    //Center 2 px VT
    [self sendThisMessage:@"(UTP5 "];
    [self sendThisMessage:[NSString stringWithFormat:@"%d", _centerLeft]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:[NSString stringWithFormat:@"%d", _centerLeft]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
    [self sendThisMessage:_userRGB];
    [NSThread sleepForTimeInterval:0.02f];
    [self sendThisMessage:@"(UTP5 "];
    [self sendThisMessage:[NSString stringWithFormat:@"%d", _centerRight]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:[NSString stringWithFormat:@"%d", _centerRight]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
    [self sendThisMessage:_userRGB];
    [NSThread sleepForTimeInterval:_delayInSeconds];
    i = 0;
    
    while (i < ((_gridBoxesHigh/2)+1)) {
        //Horizontal lines from top to middle
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:[NSString stringWithFormat:@"%ld",(long)([[_projGrid objectAtIndex:0] integerValue])]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",[[_projGrid objectAtIndex:1] integerValue]+(i * _gridsize)])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:[NSString stringWithFormat:@"%ld",(long)([[_projGrid objectAtIndex:2] integerValue])]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",[[_projGrid objectAtIndex:1] integerValue]+(i * _gridsize)])];
        [self sendThisMessage:_userRGB];
        [NSThread sleepForTimeInterval:_delayInSeconds];
        //Horizontal lins from bottom to middle
        [self sendThisMessage:@"(UTP5 "];
        [self sendThisMessage:[NSString stringWithFormat:@"%ld",(long)([[_projGrid objectAtIndex:0] integerValue])]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",[[_projGrid objectAtIndex:3] integerValue]-(i * _gridsize)])];
        [self sendThisMessage:@" "];
        [self sendThisMessage:[NSString stringWithFormat:@"%ld",(long)([[_projGrid objectAtIndex:2] integerValue])]];
        [self sendThisMessage:@" "];
        [self sendThisMessage:([NSString stringWithFormat:@"%d",[[_projGrid objectAtIndex:3] integerValue]-(i * _gridsize)])];
        [self sendThisMessage:_userRGB];
        [NSThread sleepForTimeInterval:0.02f];
        i++;
    }
    //Center 2 px HZ
    [self sendThisMessage:@"(UTP5 "];
    [self sendThisMessage:[NSString stringWithFormat:@"%ld", (long)([[_projGrid objectAtIndex:0] integerValue])]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%d", _middleTop ])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld", (long)[[_projGrid objectAtIndex:2] integerValue]])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%d", _middleTop ])];
    [self sendThisMessage:_userRGB];
    [NSThread sleepForTimeInterval:_delayInSeconds];
    [self sendThisMessage:@"(UTP5 "];
    [self sendThisMessage:[NSString stringWithFormat:@"%ld", (long)([[_projGrid objectAtIndex:0] integerValue])]];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%d", _middleBottom ])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%ld", (long)[[_projGrid objectAtIndex:2] integerValue]])];
    [self sendThisMessage:@" "];
    [self sendThisMessage:([NSString stringWithFormat:@"%d", _middleBottom ])];
    [self sendThisMessage:_userRGB];
    [NSThread sleepForTimeInterval:_delayInSeconds];
    
NSDate *drawCallFinish = [NSDate date];
NSTimeInterval drawLength = [drawCallFinish timeIntervalSinceDate:drawCallStart];
NSLog(@"...drawcalls take %f seconds", drawLength);

NSLog(@"Reached the end of the draw calls");
    NSString* str = @"Done!";
    _drawCallFinished = str;

    
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (IBAction)clearKeyboardAction:(id)sender {
    [_ipTextField resignFirstResponder];
}


//This takes the users choice of colour from the segmentedControl and sets the value ready for the zapAction
-(void)chooseColour{
    NSInteger theIndex = [_colourSelectSegment selectedSegmentIndex];
    switch (theIndex) {
        case 0:
            _userRGB = _R;
            break;
        case 1:
            _userRGB = _G;
            break;
        case 2:
            _userRGB = _B;
            break;
        case 3:
            _userRGB = _C;
            break;
        case 4:
            _userRGB = _M;
            break;
        case 5:
            _userRGB = _Y;
            break;
        case 6:
            _userRGB = _W;
            break;
        default:
            _userRGB = _R;
            break;
    }
    
}


//Broke the setup calls off into their own method. Makes the zapAction method easier to read.
-(void)setupZap{
    
    NSLog(@"STARTING SETUP");
    NSLog(@"=============================");
    //Get the desired grid...
    NSLog(@"Chosen Projector is %@", _chosenProjector);
    
    //Set _gridBoxesWide
    _gridBoxesWide = ([[_projGrid objectAtIndex:8]integerValue]/_gridsize + 1);
    NSLog(@"_gridBoxesWide == %d", _gridBoxesWide);
    
    //Set _gridBoxesHigh
    _gridBoxesHigh = ([[_projGrid objectAtIndex:9]integerValue]/(_gridsize + 1));
    NSLog(@"_gridBoxesWide == %d", _gridBoxesHigh);
    
    //Set _centerLeft
    _centerLeft = ([[_projGrid objectAtIndex:10]integerValue]/2);
    NSLog(@"_centerLeft == %d", _centerLeft);
    
    //set _centerRight
    _centerRight = _centerLeft +1;
    NSLog(@"_centerRight == %d", _centerRight);
    
    //set _middleTop
    _middleTop = ([[_projGrid objectAtIndex:11]integerValue]/2);
    NSLog(@"_middleTop == %d", _middleTop);
    
    //Set grid colour
    [self chooseColour];
    
    //set _middleBottom
    _middleBottom = _middleTop +1;
    NSLog(@"_middleBottom == %d", _middleBottom);
    
    NSLog(@"=============================");

}


//Full IP Check method. Returns 1 if Happy 0 if Sad
-(int) checkIPAdress {
    
    everythingsOK = 1;
    if (![_ipAddress  isEqual: @""]){
        
    } else {
        everythingsOK = 0;
        NSLog(@"IP VALUE IS EMPTY");
        UIAlertView *invalidIP = [[UIAlertView alloc]
                                  initWithTitle:@"Invaild IP Adderess"
                                  message:@"Please input a vaild IP Address"
                                  delegate:nil
                                  cancelButtonTitle:@"Continue"
                                  otherButtonTitles:nil];
        [invalidIP show];
    }
    
    if ( [self validateUrl:_ipAddress] ==1){
        
        NSLog(@"IP Format Check Passed. Looks like a valid IP: xx.xx.xx.xx");
    } else {
        everythingsOK = 0;
        NSLog(@"WRONG FORMAT IP");
        UIAlertView *invalidFormatIP = [[UIAlertView alloc]
                                        initWithTitle:@"Invaild IP Adderess"
                                        message:@"Please input IP with format xx.xx.xx.xx"
                                        delegate:nil
                                        cancelButtonTitle:@"Continue"
                                        otherButtonTitles:nil];
        [invalidFormatIP show];
        
    }
    
    _pingReadout = nil;
    [self tapPing:_ipAddress];
    
    while (_pingReadout == nil){
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [self checkPingReadout];

    
    return everythingsOK;
}

// Checks to see if simple ping was a success. Opens UIAlerrt and Flags everythingsOK if ping fails
-(void)checkPingReadout{
    
    if ([_pingReadout  isEqual: @"SUCCESS"]){
        NSLog(@"Ping Success %@", _ipAddress);
    } else if ([_pingReadout  isEqual: @"FAIL"]){
        everythingsOK = 0;
        NSLog(@"Ping Fail %@", _ipAddress);
        NSString *missingHost = [NSString stringWithFormat:@"Host not found at IP:%@", _ipAddress];
        UIAlertView *missingHostAlert = [[UIAlertView alloc]
                                         initWithTitle:@"Host Not Found"
                                         message:missingHost
                                         delegate:nil
                                         cancelButtonTitle:@"Continue"
                                         otherButtonTitles:nil];
        [missingHostAlert show];
        
    }

    
}


//Opens up the Comms stream to the projector
- (void)initNetworkCommunication {

    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, CFBridgingRetain(_ipAddress), _thePort, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    [inputStream open];
    [outputStream open];
    
}
//Sends message down the opened Comms stream
- (void)sendThisMessage:(NSString*)message{
    
    NSString *response  = [NSString stringWithFormat:@"%@", message ];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    
    // NSLog(@"%@ just written to ipAddress:%@", response, _ipAddress);
    
}

#pragma mark NSStream Delegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	// NSLog(@"stream event %i", streamEvent);
    
    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
			break;
            
		case NSStreamEventErrorOccurred:{
			NSLog(@"Can not connect to the host!");
            
            NSError* error = [theStream streamError];
            
            NSString* errorMessage = [NSString stringWithFormat:@"%@ (Code = %d)",
                                      [error localizedDescription],
                                      [error code]];
            UIAlertView *wifiLostAlert = [[UIAlertView alloc]
                                          initWithTitle:@"Stream Error"
                                          message:errorMessage
                                          delegate:nil
                                          cancelButtonTitle:@"Continue"
                                          otherButtonTitles:nil];
            [wifiLostAlert show];
    
			break;
        }
		case NSStreamEventEndEncountered:
			[theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
		default:
			NSLog(@"Unknown event");
	}

}



#pragma mark Pickerview Datasource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)gridPicker{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)gridPicker numberOfRowsInComponent:(NSInteger)component{
    return _gridNames.count;
}

-(NSString *) pickerView:(UIPickerView *)gridPicker titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _gridNames[row];
}

#pragma mark Pickerview Delegate

-(void) pickerView:(UIPickerView *)gridPicker didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedGrid = [gridPicker selectedRowInComponent:0];
    NSLog(@"Selected grid is %lu", (unsigned long)_selectedGrid);
    switch ((int)_selectedGrid) {
        case 0:
            _projGrid = _sxga_sxga;
            _chosenProjector = @"_sxga_sxga";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        case 1:
            _projGrid = _hd_sxga;
            _chosenProjector = @"_hd_sxga";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        case 2:
            _projGrid = _hd_hd;
            _chosenProjector = @"_hd_hd";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        case 3:
            _projGrid = _wuxga_sxga;
            _chosenProjector = @"_wuxga_sxga";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        case 4:
            _projGrid = _wuxga_hd;
            _chosenProjector = @"_wuxga_hd";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        case 5:
            _projGrid = _wuxga_wuxga;
            _chosenProjector = @"_wuxga_wuxga";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
        default:
            _projGrid = _sxga_sxga;
            _chosenProjector = @"_sxga_sxga";
            NSLog(@"Chosen projector is %@", _chosenProjector);
            break;
    }

}

// Resigns first responder for _ipTextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    _ipAddress = _ipTextField.text;
    return YES;
}

// This method checks to see if the input ip address consists of 4 quads separated by dots.
- (int) validateUrl: (NSString *) ipAddressStr{
    NSString *ipValidStr = ipAddressStr;
    NSString *ipRegEx =
    @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:ipValidStr];
    
    //NSLog(@"myStringMatchesRegEx = %d ",myStringMatchesRegEx);
    if (myStringMatchesRegEx){
        return 1;
    } else {
        return 0;
    }
    
}

// Next 3 Methods part of PingHelper. Used to Ping the input IP before passing it to the initcommunications method.
              
- (void)tapPing: (NSString*)testIP {

    [SimplePingHelper ping:testIP target:self sel:@selector(pingResult:)];
}
              
- (void)pingResult:(NSNumber*)success {

    if (success.boolValue) {
        
        [self log:@"SUCCESS"];
    } else {
        
        [self log:@"FAIL"];
    }
}

- (void)log:(NSString*)str {
	self.results.text = [NSString stringWithFormat:@"%@%@\n", self.results.text, str];
	NSLog(@"log: %@", str);
    _pingReadout = str;

}

@end
