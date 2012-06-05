# Hammer #

A Key/Value store library.

## API ##

* Key/Value store: Get/Set/Remove values.
* Lists manipulation: Push/Pop/Shift/List values.  

### Example ###

Key/Value:

    [HMRStore sharedInstance] value:@"bastos" forKey:@"user" error:NULL];
    [HMRStore sharedInstance] valueforKey:@"user" error:NULL];
    [HMRStore sharedInstance] removeValueForKey:@"user" error:NULL];

Lists:

    [HMRStore sharedInstance] pushValue:@"1" toList:@"test" error:NULL];
    [HMRStore sharedInstance] pushValue:@"2" toList:@"test" error:NULL];    
    [HMRStore sharedInstance] popValueFromList:@"test" error:NULL];
    [HMRStore sharedInstance] shiftValueFromList:@"test" error:NULL];    
    [HMRStore sharedInstance] valuesFromList:@"test" error:NULL];

## Using Hammer ##

Just copy  HMRStore.m and HMRStore.h to your project, keep in mind that Hammer uses ARC.

You can also use as a static library.

_*Hammer was tested on iOS 4.3 and 5.1._

## License ##

MIT License (read LICENSE)

## Authors ##

* Tiago Bastos <bastos@guildahq.com>