//
//  RegEdit.m
//  RegEdit
//
//  Created by Keith Lee on 5/13/13.
//  Copyright (c) 2013 Keith Lee. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//   1. Redistributions of source code must retain the above copyright notice, this list of
//      conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright notice, this list
//      of conditions and the following disclaimer in the documentation and/or other materials
//      provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY Keith Lee ''AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Keith Lee OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Keith Lee.

#import "RegEdit.h"
#import "RegEditConstants.h"

@interface RegEdit()

@property (readwrite) uint32 regSetting;

@end

@implementation RegEdit

- (id) initWithValue:(uint32)value
{
  if ((self = [super init]))
  {
    _regSetting = value;
  }
  return self;
}

- (id) objectAtIndexedSubscript:(NSInteger)index
{
  NSUInteger byteNumber = index * 8;
  if ((1 << byteNumber) > self.regSetting)
  {
    [NSException raise:NSRangeException
                format:@"Byte selected (%ld) exceeds number value", index];
  }
  unsigned int byteValue = (self.regSetting & (kByteMultiplier << byteNumber)) >>
  byteNumber;
  return [NSNumber numberWithUnsignedInt:byteValue];
}

- (void) setObject:(id)newValue atIndexedSubscript:(NSInteger)index
{
  if (newValue == nil)
  {
    [NSException raise:NSInvalidArgumentException
                format:@"New value is nil"];
  }
  
  NSUInteger byteNumber = index * 8;
  if ((1 << byteNumber) > self.regSetting)
  {
    [NSException raise:NSRangeException
                format:@"Byte selected (%ld) exceeds number value", index];
  }
  uint32 mask = ~(kByteMultiplier << byteNumber);
  uint32 tmpValue = self.regSetting & mask;
  unsigned char newByte = [newValue unsignedCharValue];
  self.regSetting = (newByte << byteNumber) | tmpValue;
}

@end
