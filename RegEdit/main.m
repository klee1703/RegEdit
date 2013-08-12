//
//  main.m
//  RegEdit
//
//  Created by Keith Lee on 5/13/13.
//  Copyright (c) 2013 Keith Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegEdit.h"
#import "CLIParser.h"

int main(int argc, const char * argv[])
{
  @autoreleasepool
  {
    // First retrieve command line arguments using CLI parser
    CLIParser *parser = [[CLIParser alloc] initWithCount:argc arguments:argv];
    uint32 registerValue;
    NSInteger registerByte;
    unsigned int byteValue;
    BOOL isSetByte;
    NSError *error;
    BOOL success = [parser parseWithRegister:&registerValue
                                  byteNumber:&registerByte
                                   doSetByte:&isSetByte
                                   byteValue:&byteValue
                                       error:&error];
    if (!success)
    {
      // log error and quit
      if (error)
      {
        NSLog(@"%@", [error localizedDescription]);
        return -1;
      }
    }
    else
    {
      // Now create a RegEdit instance and set its initial value
      RegEdit *regEdit = [[RegEdit alloc] initWithValue:registerValue];
      NSLog(@"Initial register settings -> 0x%X", (uint32)[regEdit regSetting]);
      
      // Get selected register byte using custom subscripting
      NSNumber *byte = regEdit[registerByte];
      NSLog(@"Byte %ld value retrieved -> 0x%X", (long)registerByte, [byte intValue]);
      
      // Set selected register byte to input value using custom subscripting
      if (isSetByte)
      {
        NSLog(@"Setting byte %d value to -> 0x%X", (int)registerByte, byteValue);
        regEdit[registerByte] = [NSNumber numberWithUnsignedInt:byteValue];
        NSLog(@"Updated register settings -> 0x%X", [regEdit regSetting]);
      }
    }
  }
  return 0;
}


