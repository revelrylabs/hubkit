# Setup for Development

```
bundle install
```

should be sufficient to install dependencies.

You will a `.env` file with your API keys to record new tests against the
API. Your API key will be omitted from the test cassettes by VCR. The format for
`.env` is:

```
GITHUB_TOKEN=YOUR-API-TOKEN
```

# Submitting Changes

1. Fork the repository.
2. Set up the gem per the instructions above and ensure `bundle exec rake spec`
   runs cleanly.
3. Create a topic branch.
4. Add specs for your unimplemented feature or bug fix.
5. Run `bundle exec rake spec`. If your specs pass, return to step 4.
6. Implement your feature or bug fix.
7. Re-run `bundle exec rake spec`. If your specs fail, return to step 6.
8. Open coverage/index.html. If your changes are not completely covered by the
   test suite, return to Step 4.
9. Thoroughly document and comment your code.
10. Run `bundle exec rake doc:yard` and make sure your changes are documented.
11. Add, commit, and push your changes.
12. Submit a pull request.
