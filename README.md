
#  Дипломная работа по профессии «Системный администратор»

**Группа:** **SYS-19**  <br/> Игорь Левин

**период обучения:** 28 сентября 2022 — 30 октября 2023

---
Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 
---
* [Дипломный проект](#Дипломный-проект)
    * [Структура проекта](#Структура-проекта)
	* [Установка виртульных машин](#Установка-виртульных-машин)
	* [Мониторинг серверов](#Мониторинг-серверов)
	
---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

Так как прерываемая ВМ проработает не больше 24ч, после сдачи работы на проверку свяжитесь с вашим дипломным руководителем и договоритесь запустить инфраструктуру к указанному времени.

**Продвинутый вариант:** Вместо создания обычной ВМ, создайте Instance Groups с прерываемыми ВМ. После остановки работы ВМ, Instance Groups автоматически их запустит. Подробности в  [инструкции](https://cloud.yandex.ru/docs/compute/concepts/instance-groups/). 

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования. 

1. Для Zabbix можно реализовать разделение компонент - frontend, server, database. Frontend отдельной ВМ поместите в публичную подсеть, назначте публичный IP. Server поместите в приватную подсеть, настройте security group на разрешение трафика между frontend и server. Для Database используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Zabbix, через filebeat. Можно использовать logstash тоже.
4. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

## Выполнение работы
На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

⚠️ В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

**Важно**: Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

## Критерии сдачи
1. Инфраструктура отвечает минимальным требованиям, описанным в [Задаче](#Задача).
2. Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Zabbix).
3. Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.
4. Работа оформлена в отдельном репозитории в GitHub или в [Google Docs](https://docs.google.com/), разрешён доступ по ссылке. 
5. Код размещён в репозитории в GitHub.
6. Работа оформлена так, чтобы были понятны ваши решения и компромиссы. 
7. Если использованы дополнительные репозитории, доступ к ним открыт. 

## Как правильно задавать вопросы дипломному руководителю
Что поможет решить большинство частых проблем:
1. Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать [здесь](https://app.prntscr.com/ru/).

Что может стать источником проблем:
1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения дипломной работы на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

---

## Дипломный проект

---

Начнем разработку отказоустойчивой инфраструктуры для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Для обеспечения безопасности доступ к серверам реализован через сервер-бастион **("bastion-elvm")**, имеющий внешний ip-адрес и доступный 22 порт для подключения по ssh. В общей локальной сети находятся другие сервера: два веб-сервера, Zabbix сервер, Kibana, Elasticsearch.

Развертывание всей инфракструктуры производим через **Terraform**, установку и настройку необходимого ПО через **Ansible**.
В проекте на Yandex Cloud используется **Платформа Intel Ice Lake**, конфигурация задается параметром **platform_id = "${var.platform["v3"]}"** что соответсвует переменной **"standard-v3"** в файле **variables.tf**. Для отказоустойчивой работы для серверов **Elasticsearch** и **Kibana** выделено **8Гб** оперативной памяти.

Для развертывания идентичных веб серверов в файле **websrv-elvm.tf** приписываю необходимую конфигурацию.

```sql
  resources {
    core_fraction = 20 # производительность 20%
    cores  = 2 # процессор: 2 ядра
    memory = 2 # оперативная память 2 Гб
  }
  
  scheduling_policy {
    preemptible = true # прерываемая
  }
```

На каждом из серверов установен основной загрузочный диск размером 10Гб, с операционной системой **debian_10** , для **Zabbix-сервера** используется **debian_11** .

```sql
  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

```

Две виртуальные машины **websrv-elvm-1** и **websrv-elvm-2** расположены в разных зонах: **"zone_a"** и **"zone_b"**. Переменные задаются в файле **variables.tf**

```sql
variable "zone_data" {
  type = map
  default = {
   "zone_a" = "ru-central1-a"
   "zone_b" = "ru-central1-b"
  }
}
```

Теперь настраиваю балансировщик нагрузки: Создаю Target Group - "elvm-tg", в которую добавлю подсети веб-серверов , создаю backend group и HTTP router и конфигурирую load balancer. Порт 80 используемый веб сервером nginx. healthcheck c настройками:  timeout = "1s" и interval = "1s".

```sql
    healthcheck {
      timeout              = "1s"
      interval             = "1s"
      http_healthcheck {
        path               = "/"
      }
    }

```

Для автоматизации установки инфраструктуры через **terraform** создаем файл **inventory** используемый в Ansible.  
Использую роли для управления установкой необходимого ПО.

```sql
ansible
├── roles
│   ├── bastion
│   ├── elasticsearch
│   ├── filebeat
│   ├── kibana
│   ├── nginx
│   ├── zabbix
│   └── zabbix-agent
├── install.yml
└── template
```


![tree-ansible-roles-L2.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/tree-ansible-roles-L2.JPG)


## Структура проекта 

Структура проекта выглядит так: 

```sql
.
├── ansible
│   ├── install.yml
│   ├── inventory
│   ├── roles
│   └── template
├── ansible.cfg
├── bastion-elvm.tf
├── elk-elvm.tf
├── metadata
│   ├── bastion.yml
│   └── servers.yml
├── network.tf
├── provider.tf
├── snapshots.tf 
├── target-group.tf
├── variables.tf
├── websrv-elvm.tf
└── zabbix-elvm.tf
```


![tree-project-L2.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/tree-project-L2.JPG)



Ansible использует файл **inventory**, в котором определена опция "SSH ProxyCommand", позволяя подключаться к вирутальным машинам чере бастион-серевер.

структура выглядит так:

```sql
websrv-elvm:
  hosts:
    #websrv-elvm-1:
    #websrv-elvm-2:  
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    ansible_ssh_user: 'igor'
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -q bastion@#bastion-elvm"'    

```

## Установка виртульных машин

Произведем установку всех виртульных машин, а также подключим балансировщик, и настроим снапшоты загрузочных дисков.

Команда для автоматического запуска Terraform

```
terraform apply -auto-approve
```


Полученый результат:

```sql
Outputs:

bastion-elvm = "51.250.80.150"
kibana-elvm = "84.201.159.19"
load_balancer = "158.160.130.19"
zabbix-elvm = "84.201.130.19"
```


Запускаем установку программ через ansible.

```
ansible-playbook -i ansible/inventory ansible/install.yml
```

Для удобства установки создадим роли. На веб сервера установим nginx c тестовой страницей, а также zabbix-agent и filebeat. 


Структура файла **install.yml**

```sql
---
- hosts: bastion-elvm ## bastion server
  become: yes
  remote_user: bastion
  roles:
    - bastion
- hosts: websrv-elvm ## web server
  become: yes
  remote_user: igor 
  roles:
    - nginx  
    - zabbix-agent
    - filebeat    
- hosts: elastic-elvm ## elastic server
  become: yes
  remote_user: igor
  roles:
    - elasticsearch    
- hosts: kibana-elvm ## kibana server
  become: yes
  remote_user: igor
  roles:
    - nginx   
    - kibana  
- hosts: zabbix-elvm ## zabbix server
  become: yes
  remote_user: igor
  roles:
    - nginx 
    - zabbix-agent    
    - zabbix

```


Так как программы - Elasticsearch, Kibana, Filebeat не удается установить из за ограничений доступа , использую собственный сервер: **"http://repo.limubai.ru"**. 

Для доступа к серверам использую  подключение по ssh через бастион-серевер, для этого изпользуется флаг `-J` (jump хост). Группа безопасности **bastion-sg** для бастион-серевера определена в файле **network.tf**, он имеет открытый 22 порт. Во внутренней сети можно использовать имя сервера либо FQDN.

Пример подключения к серверу:

```sql
ssh -i ~/.ssh/id_ed25519 -J bastion@51.250.80.150 igor@websrv-elvm-1
```


После того как завершиться процесс установки подключаемся проверим работоспособность веб-серверов

`curl -v 158.160.130.19` проверяем ответ от веб серверов, через **load balancer**

![curl_load_balancer.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/curl_load_balancer.JPG)

![curl_load_balancer2.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/curl_load_balancer2.JPG)

также можно открыть веб браузер и посмотреть тестовую веб-страницу. [Webservers](http://158.160.130.19 "Webservers")

На простом html/css для вебсервера **nginx** создал тестовую страницу, содержащую кнопки перехода на сервера: Zabbix и Kibana, а также на сайт Нетологии. Заголовок старницы отображает мой логотип и переход на страницу Дипломного проекта в GitHub,а также название используемого в данный момент веб-сервера. Также для удобства перезагрузки страницы создана кнопка **Перезагрузка**, в заголовке старницы отображается имя сервера. 

![website.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/website.JPG)


От веб-серверов логи  (access.log, error.log ) nginx передаются через filebeat в Elasticsearch и выводятся в  Kibana.  

Для автоматизации настройки Kibana, через Ansible создаю  индекс filebeat.


```sql
- name: post to consul
  uri:
    url: http://localhost:5601/api/saved_objects/index-pattern/filebeat-web-*?overwrite=true
    method: POST
    headers:
      Content-Type: application/json
      kbn-xsrf: this_is_required_header
    body_format: json
    body:
      attributes:
        title: filebeat-web-*
        timeFieldName: '@timestamp'
    return_content: yes
    status_code: 200
  async: 30  # it will timeout after ~30 seconds (approx)...
```



На каждом из веб серверов в конфигурацию filebeat указываю index : "filebeat-web-%{[agent.version]}-%{+yyyy.MM.dd}"

```sql
filebeat.inputs:
- type: log
  paths:
    - /var/log/nginx/access.log
- type: log
  paths:
    - /var/log/nginx/error.log
processors:
- add_docker_metadata:
    host: "unix:///var/run/docker.sock"

- decode_json_fields:
    fields: ["message"]
    target: "json"
    overwrite_keys: true

output.elasticsearch:
  hosts: ["http://elastic-elvm:9200"]
  indices:
    - index: "filebeat-web-%{[agent.version]}-%{+yyyy.MM.dd}"

logging.json: true
logging.metrics.enabled: false
```

![index_management.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/index_management.JPG)


Данные начинают поступать на сервер


![elastic.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/elastic.JPG)



## Мониторинг серверов

Ansible устанавливает на веб сервера zabbix-agent, данные передаются на Zabbix-сервер.

Через API передаю в Zabbix данные о хостах, также создаю item с параметрами мониторинга.

Пример создания Item. Код выполняется на стороне сервера.

```sql
- name: Create Item
  uri:
    url: http://127.0.0.1/api_jsonrpc.php
    method: POST
    body_format: json
    body:
      jsonrpc: "2.0"
      method: item.create
      params:
        name: "{{ item.name }}"
        key_: "{{ item.key }}"
        hostid: "{{ zabbix_template }}"
        type: 0
        value_type: 3
        delay: 60s
      auth: "{{ zabbix_auth_key }}"
      id: 3
    headers:
      Content-Type: "application/json-rpc"
    validate_certs: no
  with_items: "{{ item_response }}" 
  register: item_response

```


![zabbix-dashboard.JPG](https://github.com/elekpow/diplom-sys19/blob/main/images/zabbix-dashboard.JPG)




