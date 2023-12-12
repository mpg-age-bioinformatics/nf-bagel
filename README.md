# nf-bagel

Run the workflow:
```
RELEASE=1.0.0
nextflow runmpg-age-bioinformatics/nf-bagel -r ${RELEASE} -params-file ${PARAMS}  -entry images && \
nextflow run mpg-age-bioinformatics/nf-bagel -r ${RELEASE} -params-file params.json -entry preprocess && \
nextflow run mpg-age-bioinformatics/nf-bagel -r ${RELEASE} -params-file params.json && \
```

### `params.json`
```
{ 
  # path to mageck count counts.count.txt
  "ouput_mageck_count" : "/nexus/posix0/MAGE-flaski/service/hpc/home/jboucas/nextflow-crispr-data/mageck_output/fastq" ,

  # a tabular file of the form <label>\t<something>\t<control1>,<control2>,<controli>\t<treatment1>,<treatment2>,<treatmenti>
  "samples_tsv" : "/nexus/posix0/MAGE-flaski/service/hpc/home/jboucas/nextflow-crispr-data/samples.tsv" ,

  # where the output should go
  "output_bagel":"/nexus/posix0/MAGE-flaski/service/hpc/home/jboucas/nextflow-crispr-data/bagel_output",

  # bagel essential genes (within the bage image)
  "bagel_essential":"/bagel/CEGv2.txt",
  
  # bagel nonessential genes (within the bage image)
  "bagel_nonessential":"/bagel/NEGv1.txt"
}
```

## Contributing

Make a commit, check the last tag, add a new one, push it and make a release:
```
git add -A . && git commit -m "<message>" && git push
git describe --abbrev=0 --tags
git tag -e -a <tag> HEAD
git push origin --tags
gh release create <tag> 
```