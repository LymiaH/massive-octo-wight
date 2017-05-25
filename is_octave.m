% From octave wiki: http://wiki.octave.org/Compatibility 
 function r = is_octave()
   persistent x;
   if (isempty (x))
     x = exist ('OCTAVE_VERSION', 'builtin');
   end
   r = x;
 end
 