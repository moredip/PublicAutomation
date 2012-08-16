
# PublicAutomation

PublicAutomation is a wrapper around the private framework used by Apple's UIAutomation tools.

PublicAutomation exposes a nice Objective C API for simulating user interactions (touches, swipes, etc.).

PublicAutomation is very young, but already exposes enough functionality to write test automation scripts for most apps.

PublicAutomation is best used together with a view selection library (like [Shelley](http://github.com/TestingWithFrank/Shelley) or [Igor](http://github.com/dhemery/Igor)) and a nice high-level testing framework (like [Cucumber](http://cukes.info)). You should use [Frank](http://testingwithfrank.com) for that. It ties PublicAutomation and these other tools together for you in a pretty bow.

# Show me code
 
### Tap
    [UIAutomationBridge tapView:myView];
    // or
    [UIAutomationBridge tapView:myView atPoint:CGPointMake(12.0,34.0)];

### Swipe
    [UIAutomationBridge swipeView:myView inDirection:PADirectionLeft];
    
### Type
    [UIAutomationBridge tapView:myTextField];
    if( [UIAutomationBridge checkForKeyboard] ){
      [UIAutomationBridge typeIntoKeyboard:@"ZOMG I am typing. 123 and $%^ work too!"];
    }


## Credits

PublicAutomation uses a modified version of [KIF](http://github.com/square/KIF)'s awesome keyboard-typing code. Thanks guys!

## License
Copyright 2012 ThoughtWorks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
