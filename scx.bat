@echo off
echo Making SCXvid keyframes...
set video=%~1
set video2=%~n1

echo FFvideosource("%video%") > "%video2%_keyframes.avs"
echo SCXvid("%video2%_keyframes.log") >> "%video2%_keyframes.avs"
avsmeter "%video2%_keyframes.avs"
del "%video2%_keyframes.avs"
del "%video%.ffindex"
echo Keyframes complete
@pause