# Provider declaration
terraform {
  required_providers {
    aci = {
        source = "CiscoDevNet/aci"
    }
  }
}

# Sigle site
# Provider configuration
provider "aci" {
    url = "https://sandboxapicdc.cisco.com"
    username = "admin"
    password = "!v3G@!4@Y"
}

#Tanent
resource "aci_tenant" "tenantLocalName" {
  name = "vanilla"
}

# VRF
resource "aci_vrf" "vrfLocalName" {
    name = "global_vrf"
    tenant_dn = aci_tenant.tenantLocalName.id
  }

#bridge domain
resource "aci_bridge_domain" "bdLocalName" {
    name = "global_bd"
    tenant_dn = aci_tenant.tenantLocalName.id
    relation_fv_rs_ctx = aci_vrf.vrfLocalName.id
  
}
#subent
resource "aci_subnet" "subnetLocalName" {
    parent_dn = aci_bridge_domain.bdLocalName.id
    ip = "10.0.0.1/24"
    scope = [ "public" ]
  
}
#application profile 
resource "aci_application_profile" "apLocalName" {
    tenant_dn = aci_tenant.tenantLocalName.id
    name = "3tier-ap"  
}
#web epg
resource "aci_application_epg" "webEpgLocalName" {
    for_each = toset{["web1.epg","web2_epg"]}
    name = each.value
    application_profile_dn = aci_application_profile.apLocalName.id
    relation_fv_rs_bd = aci_bridge_domain.bdLocalName.id
    pref_gr_memb = "include"
}
#App epg
resource "aci_application_epg" "appEpgLocalName" {
    name = "app_epg"
    application_profile_dn = aci_application_profile.apLocalName.id
    relation_fv_rs_bd = aci_bridge_domain.bdLocalName.id
    pref_gr_memb = "include"
}
#vzAny for VRF
resource "aci_any" "anyLocalName" {
    vrf_dn = aci_vrf.vrfLocalName.id
}