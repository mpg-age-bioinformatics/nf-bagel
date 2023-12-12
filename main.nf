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

process probagel {
  stageInMode 'symlink'
  stageOutMode 'move'

  input:
    val control
    val treatment
    val label

  when:
    ( ! file("${params.output_bagel}/${label}.br").exists() )
  
  script:
    """
    /bagel/BAGEL.py fc -i ${params.ouput_mageck_count}/counts.count.txt -o ${params.output_bagel}/${label} -c ${control}
    /bagel/BAGEL.py bf -i ${params.output_bagel}/${label}.foldchange  -o ${params.output_bagel}/${label}.bf -e ${params.bagel_essential} -n ${params.bagel_nonessential} -c ${treatment}
    /bagel/BAGEL.py pr -i ${params.output_bagel}/${label}.bf -o ${params.output_bagel}/${label}.br -e ${params.bagel_essential} -n ${params.bagel_nonessential}
    """
}

workflow images {
  main:
    get_images()
}

workflow {
  if ( ! file("${params.output_bagel}").isDirectory() ) {
    file("${params.output_bagel}").mkdirs()
  }

  rows=Channel.fromPath("${params.samples_tsv}", checkIfExists:true).splitCsv(sep:';')
  rows=rows.filter{ ! file( "${params.output_bagel}/${it[0]}.br" ).exists() }
  label=rows.flatMap { n -> n[0] }
  control=rows.flatMap { n -> n[2] }
  treatment=rows.flatMap { n -> n[3] }

  probagel( control, treatment, label)
}