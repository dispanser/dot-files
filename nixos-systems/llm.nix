{pkgs, ...}: let
  models = "/home/data/models/huggingface/";
  # pkgs.linkFarm "llm-models" {
# # 
  #   "Mistral-Small-24B-Instruct-2501-IQ4_XS.gguf" = pkgs.fetchurl {
  #     name = "Mistral-Small-24B-Instruct-2501-IQ4_XS.gguf";
  #     url = "https://huggingface.co/bartowski/Mistral-Small-24B-Instruct-2501-GGUF/blob/main/Mistral-Small-24B-Instruct-2501-IQ4_XS.gguf";
  #     sha256 = "0qpwp704mxbmsz5w8695nzb7mhw71y7s922qvbwmpfgma7sv1ndy";
  #   };

  #   "DeepSeek-R1-Distill-Qwen-32B-Q4_K_M.gguf" = pkgs.fetchurl {
  #     name = "DeepSeek-R1-Distill-Qwen-32B-Q4_K_M.gguf";
  #     url = "https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-32B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-32B-Q4_K_M.gguf?download=true";
  #     sha256 = "0qpwp704mxbmsz5w8695nzb7mhw71y7s922qvbwmpfgma7sv1ndy";
  #   };
  # };
in {
  environment.systemPackages = with pkgs; [
    rocmPackages.rocminfo
    llama-cpp
  ];

  services.ollama = {
    enable = false;
    package = pkgs.ollama-rocm;
  };

  services.llama-cpp.enable = true;
  services.llama-cpp.model = "${models}/Mistral-Small-24B-Instruct-2501-IQ4_XS.gguf";
  services.llama-cpp.extraFlags = [
    "--temp"
    "0.6" # recommended for R1
  ];
  services.llama-cpp.port = 9001;
}
