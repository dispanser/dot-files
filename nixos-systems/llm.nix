{ pkgs, ... }:
let
  llama-rocm = /home/data/llama/rocm/bin/llama-server;
  models = "/home/data/models/huggingface";
in
{
  environment.systemPackages = with pkgs; [
    rocmPackages.rocminfo
    nvtopPackages.amd
    radeontop
    lact
    llama-swap
  ];

  services.ollama = {
    enable = false;
    package = pkgs.ollama-rocm;
  };

  services.llama-cpp = {
    enable = false;
    model = "${models}/Mistral-Small-24B-Instruct-2501-IQ4_XS.gguf";
    extraFlags = [
      "--temp"
      "0.6" # recommended for R1
    ];
    port = 9001;
  };

  services.llama-swap = {
    enable = false;
    port = 3333;
    settings = {
      healthCheckTimeout = 60;
      models = {
        "devstral2" = {
          env = [
            "HIP_VISIBLE_DEVICES=0"
          ];
          cmd = "\${server} \ --model ${models}/mistral/mistralai_Devstral-Small-2-24B-Instruct-2512-IQ4_XS.gguf -ngl 99 --jinja \${q8-kv} \ --ctx-size 45056 \ ";
          aliases = [
            "the-best"
          ];
        };
        # "gpt-oss-120b" = {
        #   env = {
        #     HIP_VISIBLE_DEVICES = 0;
        #   };
        #   proxy = "http://127.0.0.1:5555";
        #   cmd = ''\${server} \
        #       --model ${models}openai/gpt-oss-120b-F16.gguf -ngl 99 --jinja --n-cpu-moe 99 \${q8-kv} \
        #       --ctx-size 0 \
        #       -ub 4096 -b 4096
        #   '';
        #   concurrencyLimit = 4;
        # };
      };
      macros = {
        server = "${llama-rocm} --port \${PORT} --host 0.0.0.0 --jinja --no-webui";
        q8-kv = "--cache-type-k q8_0 --cache-type-v q8_0";
      };

      };
  };
}
 # /home/data/llama/rocm/bin/llama-server \
 #    --model  \
