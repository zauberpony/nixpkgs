{ stdenv, fetchFromGitHub, apacheKafka }:

stdenv.mkDerivation rec {
  name = "confluent-${version}";

  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "confluentinc";
    repo = "confluent-cli";
    rev = "v${version}";
    sha256 = "1kdbz7y67h1fdc4y04r6w5m1znrfya4zx6z1s8hrj528kmnyf1ld";
  };

  buildPhase = ''
    export CONFLUENT_HOME=$out 
    make
  '';

  installPhase = ''
    make install

    # fake a file that confluent-cli uses to check if everything is being installed correctly
    mkdir -p $out/etc/schema-registry
    touch $out/etc/schema-registry/connect-avro-distributed.properties

    # link relevant config files 
    mkdir -p $out/etc/kafka
    ln -s ${apacheKafka}/config/zookeeper.properties $out/etc/kafka/
    ln -s ${apacheKafka}/config/server.properties $out/etc/kafka/

    # link  required binaries
    ln -s ${apacheKafka}/bin/zookeeper-server-start.sh $out/bin/zookeeper-server-start
    ln -s ${apacheKafka}/bin/kafka-server-start.sh $out/bin/kafka-server-start
  '';


  meta = with stdenv.lib; {
    description = "A CLI to start and manage Confluent Platform from command line";
    homepage = https://github.com/confluentinc/confluent-cli;
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ zauberpony ];
  };
}
