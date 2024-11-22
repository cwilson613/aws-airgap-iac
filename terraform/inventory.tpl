zookeeper:
  hosts:
%{ for dns in zookeeper_dns ~}
    ${dns}:
%{ endfor ~}

%{ if length(kafka_controller_dns) > 0 }
kafka_controller:
  hosts:
%{ for dns in kafka_controller_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

kafka_broker:
  hosts:
%{ for dns in kafka_broker_dns ~}
    ${dns}:
%{ endfor ~}

control_center:
  hosts:
%{ for dns in control_center_dns ~}
    ${dns}:
%{ endfor ~}

schema_registry:
  hosts:
%{ for dns in schema_registry_dns ~}
    ${dns}:
%{ endfor ~}

ksql:
  hosts:
%{ for dns in ksql_dns ~}
    ${dns}:
%{ endfor ~}