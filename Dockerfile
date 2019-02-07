FROM r-base
RUN apt-get update && apt-get install -y \
	libcurl4-gnutls-dev \
	libssl-dev \
	libxml2-dev
CMD ['bash']
