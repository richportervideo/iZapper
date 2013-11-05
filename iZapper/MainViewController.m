//
//  MainViewController.m
//  iZapper
//
//  Created by Rich Porter on 27/10/2013.
//  Copyright (c) 2013 Rich Porter. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController  ()

@end

@implementation MainViewController {
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString * _ipAddress;
    NSArray *_sxga_sxga, *_hd_sxga, *_hd_hd, *_wuxga_sxga, *_wuxga_hd, *_wuxga_wuxga, *_gridNames;
    NSString *_R, *_G, *_B, *_C, *_Y, *_M, *_W, *_shadedRGB, *_chosenProjector, *_userRGB;
    int _gridBoxesWide, _gridBoxesHigh, _centerLeft, _centerRight, _middleTop, _middleBottom, _gridsize, _delayBtwLines, _thePort;
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
    
    _gridNames = [NSArray arrayWithObjects:@"_sxga_sxga",@"hd_sxga", @"hd_hd", @"wuxga_sxga", @"wuxga_hd", @"wuxga_wuxga", nil];
    
    //Forces an array into _projGrid incase user doesnt touch UIPickerView
    _projGrid = _sxga_sxga;
    
    
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

- (IBAction)zapAction:(id)sender {
    
    //...Useful Setup stuff...\\
    
    
    //Get the desired grid...
    NSLog(@"ZAPMETHOD: Chosen Projector is %@", _chosenProjector);
    
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
    
    //Get IP Address
    
    if (![_ipTextField.text  isEqual: @""]){
        _ipAddress = _ipTextField.text;
        NSLog(@"IPAdresss has been set to %@", _ipAddress);
    }
    
    NSLog(@"Port number is set to %d", _thePort);
    
    //Start the Network stream to the projector
    [self initNetworkCommunication];
    
    if ([_drawOnSegment selectedSegmentIndex] == 0) {
        [self sendThisMessage:@"(ITP5)"];
        NSLog(@"Sent (ITP5) for draw on black");
    }
    
    [self sendThisMessage:@"(UTP0)"];
    
    if (3<2){
        NSLog(@"This method should never be called");
        
    } else {
        int i = 0;
        while (i < [[_projGrid objectAtIndex:7] integerValue]){
            [self sendThisMessage:@"(UTP5 "];
            [self sendThisMessage:([NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:5] integerValue]+i)])];
            [self sendThisMessage:@" "];
            [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:1] integerValue]])];
            [self sendThisMessage:@" "];
            [self sendThisMessage:([NSString stringWithFormat:@"%d",([[_projGrid objectAtIndex:5] integerValue]+i)])];
            [self sendThisMessage:@" "];
            [self sendThisMessage:([NSString stringWithFormat:@"%ld",(long)[[_projGrid objectAtIndex:3] integerValue]])];
            [self sendThisMessage:_shadedRGB];
            // NSLog(@"Vertical Shading has executed %i times", i);
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
        
        
        
    }
    
    
    NSLog(@"Reached the end of the draw calls");
    
    [inputStream close];
    [outputStream close];
    
    
}

- (IBAction)clearKeyboardAction:(id)sender {
    [_ipTextField resignFirstResponder];
    [_overwriteTextField resignFirstResponder];
}

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


- (void)sendThisMessage:(NSString*)message{
    
    NSString *response  = [NSString stringWithFormat:@"%@", message ];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    
    // NSLog(@"%@ just written to ipAddress:%@", response, _ipAddress);
    
}

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

#pragma mark NSStream Delegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %i", streamEvent);
    
    typedef enum {
        NSStreamEventNone = 0,
        NSStreamEventOpenCompleted = 1 << 0,
        NSStreamEventHasBytesAvailable = 1 << 1,
        NSStreamEventHasSpaceAvailable = 1 << 2,
        NSStreamEventErrorOccurred = 1 << 3,
        NSStreamEventEndEncountered = 1 << 4
    };
    
    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
            
			break;
            
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

@end
