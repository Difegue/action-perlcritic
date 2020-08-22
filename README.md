# GitHub Action for Perl Critic

This Action allows you to run [Perl Critic](https://metacpan.org/pod/Perl::Critic) on your codebase directly from GitHub.  
If wanted, it can also post violations as comments on commits/PRs.  

By default, Perl Critic uses a `.perlcriticrc` file, if it is present in the current directory.  
Using the action's `args`, you can override any settings, as they're passed to `perlcritic` directly.

## Secrets  

* `GITHUB_TOKEN` - **Optional**. If added, this action will post Perl Critic violations as a comment on your commit/PR.  

## Example

To run Perl Critic on the Perl scripts located in `./lib`, `./script/*`, and `./tools/install.pl`:

```yaml
- name: Perl Critic
      uses: Difegue/action-perlcritic@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
          args: ./lib/* ./script/* ./tools/install.pl
```

To run Perl Critic on the the Perl scripts located in `./cgi` with more brutal policies:

```yaml
- name: Perl Critic
      uses: Difegue/action-perlcritic@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
          args: --brutal ./cgi/*.pl
```

## License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT License](LICENSE).
