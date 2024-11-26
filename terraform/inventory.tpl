%{ if length(zookeeper_dns) > 0 }
zookeeper:
  hosts:
%{ for dns in zookeeper_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

%{ if length(kafka_controller_dns) > 0 }
kafka_controller:
  hosts:
%{ for dns in kafka_controller_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

%{ if length(kafka_broker_dns) > 0 }
kafka_broker:
  hosts:
%{ for dns in kafka_broker_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

%{ if length(control_center_dns) > 0 }
control_center:
  hosts:
%{ for dns in control_center_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

%{ if length(schema_registry_dns) > 0 }
schema_registry:
  hosts:
%{ for dns in schema_registry_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}

%{ if length(ksql_dns) > 0 }
ksql:
  hosts:
%{ for dns in ksql_dns ~}
    ${dns}:
%{ endfor ~}
%{ endif ~}