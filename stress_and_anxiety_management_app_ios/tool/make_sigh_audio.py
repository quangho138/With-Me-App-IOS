"""Phase-aligned human breath cues from rrehl's CC0 Deep Breath recording."""
from pathlib import Path
import subprocess
import imageio_ffmpeg
root=Path(__file__).resolve().parents[1]
source=root/'tool/media-source/human-breath-rrehl.mp3'
parts=[]
for index,(start,end,tempo,duration) in enumerate([(0,1.25,.8,4),(.08,1.2,1.35,1),(.08,1.2,1.35,1),(1.88,2.98,.75,8)]):
    length=(end-start)/tempo
    parts.append(f'[{index}:a]atrim=start={start}:end={end},asetpts=PTS-STARTPTS,atempo={tempo},afade=t=in:d=0.025,afade=t=out:st={length-.12}:d=0.12,apad,atrim=duration={duration}[a{index}]')
parts.append('[a0][a1][a2][a3]concat=n=4:v=0:a=1,alimiter=limit=0.8:level=false[out]')
subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-y']+['-i',str(source)]*4+['-filter_complex',';'.join(parts),'-map','[out]','-ar','44100','-ac','1',str(root/'assets/audio/sigh-breath.wav')],check=True,capture_output=True)
print('Built 14-second human breathing cue track.')
