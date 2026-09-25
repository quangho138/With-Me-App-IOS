// Original procedural nature sound beds. No third-party recordings.
// Run: node tool/generate_ambience.mjs. Produces 32-second seamless PCM loops.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const out = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../assets/audio');
fs.mkdirSync(out, {recursive:true});
const sr=24000, duration=34, length=sr*duration, fade=sr*2;
let seed=270924;
function rand(){seed=(Math.imul(1664525,seed)+1013904223)>>>0;return seed/4294967296;}
for(const kind of ['waves','birds','forest','rain','fire']){
  const channels=[];
  for(let ch=0;ch<2;ch++){
    const a=new Float64Array(length); let low=0, brown=0, smooth=0;
    for(let i=0;i<length;i++){
      const t=i/sr, white=rand()*2-1;
      low=.975*low+.025*white; brown=.999*brown+.001*white; smooth=.8*smooth+.2*white;
      const gust=.45+.3*Math.sin(t*.39)+.15*Math.sin(t*.83+2);
      if(kind==='waves') {const swell=Math.pow(.5+.5*Math.sin(t*.76+Math.sin(t*.17)*.5),2); a[i]=(low*2.2+smooth*.26)*( .23+.75*swell)+brown*1.1;}
      if(kind==='forest') a[i]=(low*2.1+smooth*.08)*gust + brown*2;
      if(kind==='birds') a[i]=(low*.8+smooth*.025)*gust;
      if(kind==='rain') a[i]=smooth*.48+low*1.3+brown*.9;
      if(kind==='fire') a[i]=low*1.2+brown*2+smooth*.04;
    }
    if(kind==='birds'){
      for(let j=0;j<47;j++){
        const begin=rand()*(duration-1), span=.07+rand()*.24, freq=1700+rand()*2600, sweep=(rand()-.35)*2200;
        for(let k=0;k<span*sr;k++) {const p=k/(span*sr), ix=Math.floor(begin*sr)+k; if(ix>=length)break;
          const t=k/sr, env=Math.pow(Math.sin(Math.PI*p),1.8);
          a[ix]+=.18*env*Math.sin(2*Math.PI*(freq*t+sweep*t*t/(2*span)+35*Math.sin(t*70)*t));
        }
      }
    }
    if(kind==='fire'||kind==='rain'){
      const events=kind==='fire'?390:200;
      for(let j=0;j<events;j++){
        const ix=Math.floor(rand()*(length-sr*.2)), span=kind==='fire'?.004+rand()*.065:.008+rand()*.035;
        const level=kind==='fire'?.04+Math.pow(rand(),4)*.34:.025+rand()*.035;
        for(let k=0;k<span*sr;k++) {const env=Math.exp(-k/(span*sr)*7)*Math.min(1,k/12);
          a[ix+k]+=level*env*(kind==='fire'?(rand()*2-1):Math.sin(k/sr*(1700+600*Math.exp(-k/100))*2*Math.PI));
        }
      }
    }
    // Equal-power overlap at the loop boundary; preserve steady ambience.
    const loop=a.slice(fade);
    for(let i=0;i<fade;i++) {const p=i/fade*Math.PI/2; loop[loop.length-fade+i]=a[length-fade+i]*Math.cos(p)+a[i]*Math.sin(p);}
    channels.push(loop);
  }
  const n=channels[0].length; let peak=0;
  for(const a of channels)for(const x of a)peak=Math.max(peak,Math.abs(x));
  const gain=Math.min(2,.78/peak), bytes=n*4, b=Buffer.alloc(44+bytes);
  b.write('RIFF');b.writeUInt32LE(36+bytes,4);b.write('WAVEfmt ',8);b.writeUInt32LE(16,16);b.writeUInt16LE(1,20);b.writeUInt16LE(2,22);b.writeUInt32LE(sr,24);b.writeUInt32LE(sr*4,28);b.writeUInt16LE(4,32);b.writeUInt16LE(16,34);b.write('data',36);b.writeUInt32LE(bytes,40);
  for(let i=0;i<n;i++)for(let ch=0;ch<2;ch++) b.writeInt16LE(Math.round(Math.max(-1,Math.min(1,channels[ch][i]*gain))*32767),44+i*4+ch*2);
  fs.writeFileSync(path.join(out,kind+'.wav'),b);
}
fs.writeFileSync(path.join(out,'README.md'),'Original procedural ambient sound beds created for With Me. Stereo 24 kHz / 16-bit PCM, 32-second loops. No third-party samples or attribution obligations. Regenerate with node tool/generate_ambience.mjs. These are synthesized interpretations, not field recordings.');
