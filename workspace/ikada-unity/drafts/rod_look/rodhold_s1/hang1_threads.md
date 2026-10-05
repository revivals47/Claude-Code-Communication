# S1 build stall 1 (worker3, 2026-10-06 05:16:52): per-thread comm / State / wchan, counted (boss1 05:16). State from /proc/<task>/status.

## pid 1754685 Unity Main Thre (cpu 00:00:49, threads 88)
```
     16 Background Job.	S	futex_wait_queue
     13 Thread Pool Wor	S	sigsuspend
      8 BakingJobs.Work	S	futex_wait_queue
      7 Burst-CompilerT	S	sigsuspend
      7 AssetGarbageCol	S	futex_wait_queue
      4 Unity Main Thre	S	futex_wait_queue
      2 Unity Main Thre	S	sigsuspend
      1 threaded-ml	S	do_poll.constprop.0
      1 pool-spawner	S	futex_wait_queue
      1 gmain	S	do_poll.constprop.0
      1 gdbus	S	do_poll.constprop.0
      1 [vkrt] Analysis	S	futex_wait_queue
      1 [vkps] Update	S	futex_wait_queue
      1 [vkcf] Analysis	S	futex_wait_queue
      1 UnityGfxDeviceW	S	futex_wait_queue
      1 Thread Pool I/O	S	sigsuspend
      1 SDLTimer	S	futex_wait_queue
      1 Profiler.Dispat	S	futex_wait_queue
      1 Loading.Preload	S	sigsuspend
      1 Loading.AsyncRe	S	futex_wait_queue
      1 Job.Worker 6	S	futex_wait_queue
      1 Job.Worker 5	S	sigsuspend
      1 Job.Worker 4	S	sigsuspend
      1 Job.Worker 3	S	sigsuspend
      1 Job.Worker 2	S	sigsuspend
      1 Job.Worker 1	S	sigsuspend
      1 Job.Worker 0	S	futex_wait_queue
      1 Finalizer	S	sigsuspend
      1 EditorTaskManag	S	hrtimer_nanosleep
      1 Debugger agent	S	sigsuspend
      1 CurlRequest	S	hrtimer_nanosleep
      1 CoreBusinessMet	S	futex_wait_queue
      1 CloudJob.Worker	S	futex_wait_queue
      1 Burst-ProgressR	S	sigsuspend
      1 BatchDeleteObje	S	futex_wait_queue
      1 Audio Stream Th	S	hrtimer_nanosleep
      1 Audio PulseAudi	S	futex_wait_queue
      1 AssetDatabase.I	S	ep_poll
```

## pid 1754711 MainThread (cpu 00:00:02, threads 11)
```
      4 libuv-worker	S	futex_wait_queue
      4 V8Worker	S	futex_wait_queue
      1 SignalInspector	S	futex_wait_queue
      1 MainThread	S	ep_poll
      1 DelayedTaskSche	S	ep_poll
```

## pid 1754886 Unity.ILPP.Runn (cpu 00:00:01, threads 12)
```
      1 Unity.ILPP.Runn	S	futex_wait_queue
      1 Kestrel Timer	S	futex_wait_queue
      1 Console logger 	S	futex_wait_queue
      1 .NET TP Gate	S	futex_wait_queue
      1 .NET SynchManag	S	do_poll.constprop.0
      1 .NET Sockets	S	ep_poll
      1 .NET SigHandler	S	pipe_read
      1 .NET Finalizer	S	futex_wait_queue
      1 .NET File Watch	S	wait_woken
      1 .NET EventPipe	S	do_poll.constprop.0
      1 .NET Debugger	S	futex_wait_queue
      1 .NET DebugPipe	S	wait_for_partner
```

## pid 1755360 UnityShaderComp (cpu 00:00:00, threads 8)
```
      1 UnityShaderComp	S	do_poll.constprop.0
      1 Job.Worker 6	S	futex_wait_queue
      1 Job.Worker 5	S	futex_wait_queue
      1 Job.Worker 4	S	futex_wait_queue
      1 Job.Worker 3	S	futex_wait_queue
      1 Job.Worker 2	S	futex_wait_queue
      1 Job.Worker 1	S	futex_wait_queue
      1 Job.Worker 0	S	futex_wait_queue
```

- reading (inference, not measured): many threads (thread pool, Burst, job workers, two 'Unity Main Thre') sit in sigsuspend = the way Mono parks threads for a stop-the-world GC; the rest wait on futexes. If stall 2 shows the same shape, compare this list.
