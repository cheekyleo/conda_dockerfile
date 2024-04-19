FROM ubuntu:22.04

ARG NB_USER="conda"
ARG NB_UID=1000760000
ARG NB_GID=1000760000

USER root

RUN apt-get update && apt-get install -yq curl wget jq vim bzip2 ca-certificates git tini nano

ENV NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID}

ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=C.UTF-8
ENV PATH=/opt/conda/bin:/home/conda/.local/bin:${PATH}

RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3-$(uname)-$(uname -m).sh -b -p /opt/conda && \
    rm Miniforge3-$(uname)-$(uname -m).sh && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc

RUN groupadd -g ${NB_GID} ${NB_USER} && \
    useradd -m --no-log-init -u $NB_UID -g 0 -o -s /bin/bash $NB_USER

ENV PATH="${CONDA_DIR}/bin:${PATH}" \
    HOME="/home/${NB_USER}"

SHELL ["/bin/bash","-l", "-c"]

RUN chgrp -R 0 /home/conda && \
    chmod -R g=u /home/conda
RUN chgrp -R 0 /opt/conda && \
    chmod -R g=u /opt/conda
WORKDIR /home/conda

USER ${NB_UID}

RUN conda install psi4 python=3.12 -c conda-forge 

ENTRYPOINT ["tini", "--"]
CMD [ "/bin/bash" ]
