/*
 
 CCAutoTypeLabelBM.m
 
 Copyright (c) 2012 EXC_BAD_ACCESS. All rights reserved.
 Original: https://github.com/sceresia/CCAutoType
 Modified by Truong Vinh Tran
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CCAutoTypeLabelBM.h"

@interface CCAutoTypeLabelBM ()

//array with all characters which are already typed
@property (nonatomic, retain) NSMutableArray *arrayOfCharacters;

//string which will be typed
@property (nonatomic, retain) NSString *autoTypeString;

@end

@implementation CCAutoTypeLabelBM

+(CCAutoTypeLabelBM*)labelWithfntFile:(NSString*)fntFileName{
    //init empty label for parent
    return [CCAutoTypeLabelBM labelWithString:@"" fntFile:fntFileName];
}


+(CCAutoTypeLabelBM*)labelWithfntFile:(NSString*)fntFileName target:(NSObject<CCAutoTypeLabelBMDelegate>*)target{
    CCAutoTypeLabelBM *instance = [CCAutoTypeLabelBM labelWithfntFile:fntFileName];
    instance.delegate = target;
    return instance;
}

- (void) typeText:(NSString*) text withDelay:(float) delay {
    
    //check wether label is already typing
    if ([self numberOfRunningActions]!=0) {
        
        //notify target object
        if ([self.delegate respondsToSelector:@selector(errorLabelStillTyping::)]) {
            [self.delegate errorLabelStillTyping:self];
        }
        return;
    }
    
    //init new array for the characters of the typing string
    self.arrayOfCharacters = [NSMutableArray new];
    
    //init new string
    self.autoTypeString = [text copy];
    
    //add every character to the typing list
    for (int j=1; j < [_autoTypeString length]+1; ++j) {
        NSString *substring = [text substringToIndex:j];
        [_arrayOfCharacters addObject:substring];
    }
    
    //schedule the typing
    for (int i=0; i < [_autoTypeString length]; ++i) {
        NSString *string = [_arrayOfCharacters objectAtIndex:i];
        CCSequence *seq = [CCSequence actions:
                           [CCDelayTime actionWithDuration:i*delay],
                           [CCCallFuncND actionWithTarget:self selector:@selector(type:data:) data:(__bridge void *)((NSString*)string)],
                           nil];
        [self runAction:seq];
    }
    
    //check every second wether it is finished
    [self schedule:@selector(finishCheck:) interval:1];
}

/** Method for typing/updating the label
 *
 *  @param sender is the target which called this method
 *  @param string is the new string
 */
- (void)type:(id) sender data:(NSString*)string {
    [self setString:string];
}

/** Helping method to check wether the string is fully typed
 *
 *  @param dt is the current time
 */
- (void) finishCheck:(ccTime)dt{
    
    //check wether actions are still running
    if ([self numberOfRunningActions] == 0) {
        
        //no actions running, stop calling the CCSequence
        [self unschedule:@selector(finishCheck:)];
        
        //notify target object
        if ([self.delegate respondsToSelector:@selector(typingFinished:)]) {
            [self.delegate typingFinished:self];
        }
    }
}

@end