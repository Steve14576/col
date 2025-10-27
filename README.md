# col-To_Run_Codes_On_Termux  
```
- Launching colL sereis, with Chinese, English and Klingon version.
- Comming up col series, function vcd, vuv, etc.
- Check the content before running them, Zhubo quite unsure of its safety or bugs, AI suggests fine, Zhubo not confident.
```
## ***General Info*** ##
- Generated with Qoder the AI IDE.
  - Zhubo knows a shxt about linux or shell script but Zhubo needs it to run codes on Zhubo's Android phone as it is really cool and Zhubo can code everywhere.
  - You this is Android logic ah.
  
- A script tool to encase calls for compilers and packages for easier use on the phone.
  - Unroot friendly, so hooray Moumi runners !
  - Script itself under Termux's `~` directory, while it links freely with your project source files within `storage`. The commands are executed within `~` so usually higher autherized.
  - Zhubo knows it is impossible to remain concise on professional tools, but dude you are working on a phone, so an fully functional IDE is, well hard to achieve. So far, Zhubo envisions using `uv` or pip-venv and git to manage. The latest progress is shown on the board above.
  - Zhubo envision a function called `vcd`, virtual directory， to be added.
  - No critical config files originally, the script on its own is fully functional. This allows easy secodnary distribution.
  
- Bilungual originally supported
  - Zhubo use AI to generate `Chinese` version and use AI to gnerate `English` version
  - Zhubo found a thing called Klingon, Zhubo happy.
- You might have heard the project “Termirun”, you might have not because it is a immature project with such cool name which it doesn't support. Now here comes the successer, the col sereis.
  
- The col series comes in 3 lineups:
  - **col** sereis: 
    - Interface & single call
    - In `.sh` script, ordinary, full function.
    - Extensions supporetd and to be added.
    - Zhubo might stuck in whatever he thinks of the next second after.
    - Has mechanism of **`vcd`**, along with **proot** environment, and capatable **extensions**, it can immitate the usage of some packages by intercepting their commands, and try to actually execute them within ~ on Android.
  - **colL** sereis: 
    - Interface
    - In `.sh` script, smaller and lighter.
    - Functions such as "vcd", "set", support for extensions are removed, 
    - Zhubo think this is good enough dude you are coding an a phone
  - **colEx** series:
    - Zhubo try use AI transfer to `Rust` and further `standalone biary` so is it concise (I hope)
    - Theoretically functions the same as the original `col` series.
    - The rest, unsure.
    
- This should be a long term projectm I hope? But Zhubo not planning to learn shell script. Zhubo needs to fucus now on learning c and numpy.
- Again this is never about to build a comprehendsive "IDE", it's about to build a handy one.
  
## ***How to use*** ##
  - Recommending working with `MT Manager` and `Acode`, recommending `rlwrap` in `Termux`.
    - MT Manager: A file manager for Andriod, able to access what the original file namager could not.
    - Acode: An handy but powerful code editor on Android. [Acode](https://github.com/deadlyjack/acode)**
    - Termux: A very powerful app functions as a `Linux` terminal simulator that can do many things even without root. [Termux](https://github.com/termux/termux-app)
  - Place and execute the script within the `~` directory of Termux, or else it's execution is enernally blokced by Android.
    - It is normal for file managers not to find `~`. Hereby recommend:
      1. Download the script and open it with a file manager.
      2. Clone the directory route, goto Termux and use command `mv` to move it to some directory within `~`.
      3. Then `cd` to the script's directory, make sure to execute it there.
  - grant a `chmod +x` or even `chmod +777` to it.
  - Directly execute them by names, as they are essentialy scripts.
    - Such as `./col13`, `./colL4`, `./colExRs3`, `./colWhateverRenamed`
    - Rename them if its comfy for you, references were not based on name strings.
    - Recommend using `rlwrap ./col`, this helps with reactivating arrows within the script environment. Termux does not come with it, so `pkg install rlwrap` if you feel you need to.
  - Help infos are within, or you can like `./col13 --help` to check help infos without officially launching it.
  - Press ctrl+C to exit the interface.
