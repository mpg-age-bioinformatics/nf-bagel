#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process get_images {
  stageInMode 'symlink'
  stageOutMode 'move'

  script:
    """

    if [[ "${params.containers}" == "singularity" ]] ; 

      then

        cd ${params.image_folder}

        if [[ ! -f bagel-53388ad.sif ]] ;
          then
            singularity pull bagel-53388ad.sif docker://index.docker.io/mpgagebioinformatics/bagel:53388ad 
        fi

    fi


    if [[ "${params.containers}" == "docker" ]] ; 

      then

        docker pull mpgagebioinformatics/bagel:53388ad 

    fi

    """

}

process prebagel {
  stageInMode 'symlink'
  stageOutMode 'move'

  when:
    ( ! file("${params.output_bagel}/bagel.preprocess.done").exists() )
  
  script:
    """
#!/usr/local/bin/python3
import os
from pathlib import Path

if not os.path.exists("${params.output_bagel}") :
  os.makedirs("${params.output_bagel}")

with open("${params.samples_tsv}","r") as samples :
  for line in samples:
    line=line.split("\\n")[0]
    l=line.split(";")
    label=l[0]
    control=l[2].replace(".fastq.gz","")
    treatment=l[3].replace(".fastq.gz","")

    cmd1=f"/bagel/BAGEL.py fc -i ${params.ouput_mageck_count}/counts.count.txt -o ${params.output_bagel}/{label} -c {control}\\n"
    cmd2=f"/bagel/BAGEL.py bf -i ${params.output_bagel}/{label}.foldchange  -o ${params.output_bagel}/{label}.bf -e ${params.bagel_essential} -n ${params.bagel_nonessential} -c {treatment}\\n"
    cmd3=f"/bagel/BAGEL.py pr -i ${params.output_bagel}/{label}.bf -o ${params.output_bagel}/{label}.br -e ${params.bagel_essential} -n ${params.bagel_nonessential}\\n"

    with open(f"${params.output_bagel}/{label}.bagel.sh", "w") as sh:
      sh.write(cmd1)
      sh.write(cmd2)
      sh.write(cmd3)

Path(f"${params.output_bagel}/bagel.preprocess.done").touch()
    """
}

process probagel {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    val shscript
    val label

  when:
    ( ! file("${params.output_bagel}/${label}.br").exists() )
  
  script:
    """
bash ${shscript}
    """
}

workflow images {
  main:
    get_images()
}

workflow preprocess{
    if ( ! file("${params.output_bagel}").isDirectory() ) {
      file("${params.output_bagel}").mkdirs()
    }
    prebagel()
}

workflow {
  data=channel.fromPath("${params.output_bagel}/*.bagel.sh" )
  data=data.filter{ ! file( "$it".replace(".bagel.sh", ".br") ).exists() }
  label = data.map{ "$it.baseName" }
  label = label.map{ "$it".replace(".bagel.sh","") }
  probagel( data, label)
}