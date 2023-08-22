# Azure SRA (In-Progress)

## Discussion points

- Privatelink Unity Catalog storage? - Yes! Unless service tags
- Privatelink DBFS? # optional? future state? -@tony
- ~~Central route table vs. spoke-bound?~~ # decided centralized
- Variable naming conventions
- State file hierarchy (one per hub?) @srijit
- Consideration of moving PL-ALL-THE-THINGS to regulated industries blueprints (dbfs, other storage, whatever else)

## TODO

- [ ] Check subnet math to make sure that the spoke vnets are fully utilized by the Databricks subnets
- [ ] Check the PL subnet (spoke, dbfs) to make sure it is tiny
- [ ] AKV in hub
- [ ] Add a diagram of the architecture
- [ ] Add a diagram of the network
- [ ] Get review from @arthur and compare with his previous work, get feedback
- [ ] Add Github issues for future improvement items to make work public/community-friendly
- [ ] Establish Github tags for issues/releases etc.
- [ ] Add a section on how to use the templates
- [ ] Incorporate CI/CD, testing, and `tfsec`
- [ ] @arthur mentioned it would be good to provide github actions to deploy the templates
- [ ] @arthur also suggested evaluating CDKs where applicable

## Future State/Enhancements

- [ ] HA/DR (w/optionality on spokes?)
