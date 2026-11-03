# Local execution and optional local AI

## Choose what “local” means

| Component | Can run on the desktop? | Internet requirement |
|---|---|---|
| Craft Anything GUI, CLI and built-in inspection | Yes | Downloads/plugins/remote targets may need network |
| Generated website/app/game | Often; depends on its architecture | Online APIs or assets may still need network |
| Video editing/rendering with local tools and footage | Yes, once implemented as a workflow | Download dependencies first; remote media/services remain online |
| Claude Code builder with Anthropic models | Local agent process; remote model | Requires internet and the owner's eligible account/access |
| Local OpenAI-compatible model backend | Supported connection type | Local inference can be offline after model/runtime downloads |
| Fully local project-building loop | Implemented API/tool-loop path, not proven here | Must pass its own offline test; no silent cloud fallback |
| Cloud image/3D generation | Not local in the current provider integration | Requires provider access; leave off unless chosen |

## Recommended order

1. Prove Craft Anything + Claude Code on the desktop.
2. Add one local model server only if wanted, e.g. LM Studio or Ollama.
3. Load a model compatible with its runtime and use the exact id the server reports.
4. Test questions, structured tool calls and a tiny build separately.
5. Keep Claude as the initial builder unless the local path demonstrates acceptable quality.

Do not silently repoint Claude Code credentials or its normal service configuration to a
local server. Configure a separate Craft Anything backend and select it explicitly.
Do not put real keys or machine-specific config in this public repository.

The fork supports an OpenAI-compatible base URL. Common local endpoints are
`http://127.0.0.1:1234/v1` (LM Studio) and `http://127.0.0.1:11434/v1` (Ollama);
verify the actual listening port and runtime documentation rather than assuming.
In Settings → AI, add/detect that server and test its model. Confirm which backend each
role actually uses. A fallback chain containing a cloud backend is not offline mode.

## Fit the model to the machine

For an 8 GB VRAM / 32 GB RAM machine class, start by benchmarking a small quantized model
with a modest context. This is a trial strategy, not a guarantee that any named model fits.
Check free memory with the desktop and other apps running. Model weights, context/KV cache,
runtime buffers and the renderer share limited GPU memory.

Do not choose a large model just because its file fits system RAM. For scale, 27 billion
parameters at an ideal four bits already represent about 13.5 GB of weights before
quantization metadata and runtime overhead. CPU/RAM offload may make it runnable, with
different speed; it cannot fully fit those weights into 8 GB VRAM. Avoid big context
windows and concurrent game/video rendering during the first inference test.

Record model id, quantization, context limit, GPU offload, peak VRAM/RAM, time to first output,
generation speed and success/failure on the test task. Do not invent a tokens-per-second claim.

## Offline acceptance test

Download the model, runtime, required SDKs and project dependencies first. Use a disposable
project and an offline profile with no cloud backends or fallback. Then test without internet:

- Open Craft Anything and ask the local model a question.
- Make the model call a harmless tool and read/write a small project file through the intended loop.
- Build an original tiny project using already cached dependencies and run it.
- Verify the actual configured endpoint, outputs and logs; record what network access was attempted.

Report “local chat works” separately from “local tools work” and “offline builds work”.
Fetching public websites, new packages or missing engine assets naturally cannot work offline.

Primary references: [LM Studio API](https://lmstudio.ai/docs/developer/openai-compat),
[system requirements](https://lmstudio.ai/docs/app/system-requirements),
[Claude Code setup](https://code.claude.com/docs/en/setup), plus the source paths in [the audit](AUDIT.md).
