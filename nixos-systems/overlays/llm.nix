self: super: {
  llm =
    rec {
      pyWithPackages = (
        super.python3.withPackages (ps: [
          ps.llm
          ps.llm-openrouter
        ])
      );
      llm = super.runCommandLocal "llm" { } ''
        mkdir -p $out/bin
        ln -s ${pyWithPackages}/bin/llm $out/bin/llm
      '';
    }
    .llm;
}
