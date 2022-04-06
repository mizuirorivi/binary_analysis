/* Demonstrate the binary loader from ../inc/loader.cc */

#include <stdio.h>
#include <stdint.h>
#include <string>
#include <yaml-cpp/yaml.h>
#include "../lib/loader.h"
#include <iostream>

/**
 * pwn_check.ymlからpwnできそうな関数を探す
 */
std::vector<my_loader::Symbol> check_pwn_function(my_loader::Binary bin){
  YAML::Node config = YAML::LoadFile("pwn_check.yml");
  std::vector<my_loader::Symbol> pwn_symbols;
  if(config["array"]){

    std::vector<std::string> pwn_check_name_array = config["array"].as<std::vector<std::string>>();
    
    if(bin.symbols.size() > 0) {
      for(int i = 0; i < bin.symbols.size(); i++) {
        my_loader::Symbol *sym = &bin.symbols[i];
        for(auto &i : pwn_check_name_array){
          std::string sym_name = sym->name.c_str();
          std::string find_str = i.c_str();
          if(sym_name.find(find_str)!=std::string::npos) {
            pwn_symbols.push_back(*sym);
          }
        }
      }
    }    
  }
  return pwn_symbols;
}
void print_section(std::vector<my_loader::Section> secs){
  printf("[*] scanned section\n");
  for(int i = 0; i < secs.size(); i++) {
    my_loader::Section *sec = &secs[i];
    printf("  0x%016jx %-8ju %-20s %s\n", 
           sec->vma, sec->size, sec->name.c_str(), 
           sec->type == my_loader::Section::SEC_TYPE_CODE ? "CODE" : "DATA");
  }
}
void print_symbol(std::vector<my_loader::Symbol> syms){
  printf("[*] scanned symbol tables\n");
  for(int i = 0; i < syms.size(); i++) {
      my_loader::Symbol *sym = &syms[i];
      printf("  %-40s 0x%016jx %s\n", 
             sym->name.c_str(), sym->addr, 
             (sym->type & my_loader::Symbol::SYM_TYPE_FUNC) ? "FUNC" : "");
  }
}
void print_pwnable_function(my_loader::Binary bin){
  std::vector<my_loader::Symbol> pwnable_symbols;
  pwnable_symbols = check_pwn_function(bin);
  std::cout << "start print pwnable function" << std::endl;
  if(pwnable_symbols.empty()){
    printf("[*] No pwnable function found\n");
  }
  else{
    printf("[*] Found pwnable function\n");
    print_symbol(pwnable_symbols);
  }
}

int
main(int argc, char *argv[])
{
  size_t i;
  my_loader::Binary bin;
  my_loader::Section *sec;
  my_loader::Symbol *sym;
  std::string fname;

  if(argc < 2) {
    printf("Usage: %s <binary>\n", argv[0]);
    return 1;
  }
  
  fname.assign(argv[1]);
  if(my_loader::load_binary(fname, &bin, my_loader::Binary::BIN_TYPE_AUTO) < 0) {
    printf("[-] Failed to load binary: %s\n", fname.c_str());
    return 1;
  }

  printf("[*] loaded binary '%s' %s/%s (%u bits) entry@0x%016jx\n", 
         bin.filename.c_str(), 
         bin.type_str.c_str(), bin.arch_str.c_str(), 
         bin.bits, bin.entry);

  print_section(bin.sections);

  if(bin.symbols.size() > 0) {
    print_symbol(bin.symbols);
  }
  print_pwnable_function(bin);
  // 不必要になったのでfree
  my_loader::unload_binary(&bin);

  return 0;
}

